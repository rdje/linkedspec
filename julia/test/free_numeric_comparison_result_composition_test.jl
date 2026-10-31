module JuliaFreeNumericComparisonResultComposition
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
    error("unexpected numeric comparison source fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:FreeNumericComparisonGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "free-numeric-comparison-result-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "free-numeric-comparison-result-composition.spec",
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
    println("FREE_NUMERIC_COMPARISON_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia numeric comparison source and short-prefix guards" begin
    check("primitive_comparisons","Value:: I {return([[num_eq(2,2),num_ne(2,3),num_gt(3,2),num_ge(2,2),num_lt(2,3),num_le(2,2),num_eq(2,3),num_ne(2,2),num_gt(2,3),num_ge(2,3),num_lt(3,2),num_le(3,2)],[2.eq(2),2.ne(3),3.gt(2),2.ge(2),2.lt(3),2.le(2),2.eq(3),2.ne(2),2.gt(3),2.ge(3),3.lt(2),3.le(2)]])}","x",JSON3.read("[[1,1,1,1,1,1,0,0,0,0,0,0],[1,1,1,1,1,1,0,0,0,0,0,0]]",Any))
    check("strict_numeric_domains","Value:: I {return([num_eq(\"02\",2),num_lt(\"-.5\",0),num_eq(false,0),num_eq(undef,0),num_eq([],0),num_eq({},0),num_eq(\" 2\",2),\"02\".eq(2),false.eq(0),\"bad\".eq(0)])}","x",JSON3.read("[1,1,null,null,null,null,null,1,null,null]",Any))
    check("compatible_values","Value:: I {return([num_eq(2,2).cat(\"!\"),num_eq(2,3).coalesce_nonempty(9).cat(\"!\"),num_lt(2,3).cat(\",tail\").split(\",\").last().uppercase(),2.eq(3).add(2)])}","x",JSON3.read("[\"1!\",\"0!\",\"TAIL\",2]",Any))
    check("free_container_guards","Value:: I {order=\"\";left=num_eq(2,3).take({order=cat(order,\"A\");1});right=num_gt(3,2).set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("receiver_container_guards","Value:: I {order=\"\";left=2.eq(3).take({order=cat(order,\"A\");1});right=3.gt(2).set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("free_guard_before_with","Value:: I {order=\"\";out=num_eq({order=cat(order,\"S\");return(2)},2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"S\"]",Any))
    check("receiver_guard_before_with","Value:: I {order=\"\";out={order=cat(order,\"S\");return(2)}.eq(2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"S\"]",Any))
    check("free_bridge_rejection","Value:: I {order=\"\";out=num_eq(2,3).split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("receiver_bridge_rejection","Value:: I {order=\"\";out=2.eq(3).split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("valid_array_bridges","Value:: I {return([num_eq(2,2).split(\",\").first().cat(\"!\"),2.eq(3).split(\",\").first().cat(\"!\")])}","x",JSON3.read("[\"1!\",\"0!\"]",Any))
    check("source_operand_snapshot","Value:: I {value=2;order=\"\";out=num_eq({order=cat(order,\"S\");return(value)},{value=99;order=cat(order,\"O\");return(2)}).cat({order=cat(order,\"C\");\"!\"});return([out,value,order])}","x",JSON3.read("[\"1!\",99,\"SOC\"]",Any))
    check("zero_typed_indices","Value:: I {slots=[\"old\"];index=num_eq(2,3).copy();slots[index]=\"free\";other=2.eq(3).copy();slots[other]=\"receiver\";return([index,other,slots])}","x",JSON3.read("[0,0,[\"receiver\"]]",Any))
    check("valid_null_with","Value:: I {order=\"\";left=num_eq(\"bad\",2).with(){order=cat(order,\"F\");return(\"free\")};right=\"bad\".eq(2).with(){order=cat(order,\"R\");return(\"receiver\")};return([left,right,order])}","x",JSON3.read("[\"free\",\"receiver\",\"FR\"]",Any))
    check("valid_empty_with","Value:: I {order=\"\";out=num_eq(\"bad\",2).coalesce([]).with(){order=cat(order,\"W\");return(value.count())};return([out,order])}","x",JSON3.read("[0,\"W\"]",Any))
    check("all_canonical_free_guards","Value:: I {order=\"\";out=[num_eq(2,2).take({order=cat(order,\"A\");1}),num_ne(2,3).take({order=cat(order,\"A\");1}),num_gt(3,2).take({order=cat(order,\"A\");1}),num_ge(2,2).take({order=cat(order,\"A\");1}),num_lt(2,3).take({order=cat(order,\"A\");1}),num_le(2,2).take({order=cat(order,\"A\");1}),num_eq(2,3).take({order=cat(order,\"A\");1}),num_ne(2,2).take({order=cat(order,\"A\");1}),num_gt(2,3).take({order=cat(order,\"A\");1}),num_ge(2,3).take({order=cat(order,\"A\");1}),num_lt(3,2).take({order=cat(order,\"A\");1}),num_le(3,2).take({order=cat(order,\"A\");1})];return([out,order])}","x",JSON3.read("[[null,null,null,null,null,null,null,null,null,null,null,null],\"\"]",Any))
    check("all_short_receiver_with_guards","Value:: I {order=\"\";out=[2.eq(2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},2.ne(3).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},3.gt(2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},2.ge(2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},2.lt(3).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},2.le(2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},2.eq(3).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},2.ne(2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},2.gt(3).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},2.ge(3).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},3.lt(2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},3.le(2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null,null,null,null,null,null,null,null,null],\"\"]",Any))
    check("function_scope","fn build(){order=\"\";left=num_eq(2,3).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};right=2.eq(3).take({order=cat(order,\"B\");1}).with(){order=cat(order,\"X\");return(\"ran\")};return([left,right,order])}\nValue:: I {value=\"caller\";return([build(),value])}","x",JSON3.read("[[null,null,\"\"],\"caller\"]",Any))
    check("valid_zero_and_one_with","Value:: I {order=\"\";zero=num_eq(2,3).with(){order=cat(order,\"F\");return(value.add(2))};one=2.eq(2).with(){order=cat(order,\"R\");return(value.add(2))};return([zero,one,order])}","x",JSON3.read("[2,3,\"FR\"]",Any))
    actual=observe("Value:: I {return(num_eq({items=\"text\";push(items,\"x\")},2).coalesce(\"masked\"))}","x")
    println("FREE_NUMERIC_COMPARISON_ERROR ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for row in values(actual)
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    shapes=Any[]
    for source in (
        "num_eq().take(1).with(){return(\"x\")}",
        "num_eq(1).take(1).with(){return(\"x\")}",
        "num_eq(1,1,1).take(1)",
        "num_eq(left:1,right:1).take(1)",
        "eq(1,1).take(1)",
        "==(1,1).take(1)",
        "num_min([1,2]).take(1)",
        "[1,2].min().with(){return(value)}",
        "str_eq(\"a\",\"a\").take(1).with(){return(\"x\")}",
        "\"a\".str_eq(\"a\").take(1).with(){return(\"x\")}",
        "1.eq().with(){return(\"x\")}",
        "1.eq(2){return(\"x\")}",
        "{|| return(num_eq(1,1).take(1)) }",
        "num_eq(1,1).map_leaves(){return(value)}",
    )
        row=try
            Dict("source"=>source,"ast"=>to_json(parse_action_expression(source)))
        catch failure
            Dict("source"=>source,"error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
        end
        push!(shapes,row)
    end
    @test length(shapes)==14
    println("FREE_NUMERIC_COMPARISON_SHAPES ",JSON3.write(shapes))
end
end # module
