module JuliaFreeNumericResultComposition
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
    error("unexpected arithmetic source fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:FreeNumericGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "free-numeric-result-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "free-numeric-result-composition.spec",
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
    println("FREE_NUMERIC_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia arithmetic source and Number-prefix guards" begin
    check("primitive_arithmetic","Value:: I {return([num_abs(-3),num_floor(3.8),num_ceil(3.2),num_round(2.5),num_add(1,2,3),num_sub(5,2),num_mul(2,3,4),num_div(7,2),num_mod(7,3),num_clamp(12,0,10),num_min(7,3,5),num_max(3,5,4)])}","x",JSON3.read("[3,3,4,3,6,3,24,3.5,1,10,3,5]",Any))
    check("compatible_values","Value:: I {return([num_add(2,3).cat(\"!\"),num_div(6,2).cat(\",tail\").split(\",\").last().uppercase(),num_add(0,0).coalesce_nonempty(9).add(1),2.add(3).cat(\"!\")])}","x",JSON3.read("[\"5!\",\"TAIL\",1,\"5!\"]",Any))
    check("free_container_guards","Value:: I {order=\"\";left=num_add(1,2).take({order=cat(order,\"A\");1});right=num_sub(5,2).set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("receiver_container_guards","Value:: I {order=\"\";left=1.add(2).take({order=cat(order,\"A\");1});right=5.sub(2).set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("free_guard_before_with","Value:: I {order=\"\";out=num_add({order=cat(order,\"S\");return(1)},2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"S\"]",Any))
    check("receiver_guard_before_with","Value:: I {order=\"\";out={order=cat(order,\"S\");return(1)}.add(2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"S\"]",Any))
    check("free_bridge_rejection","Value:: I {order=\"\";out=num_add(1,2).split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("receiver_bridge_rejection","Value:: I {order=\"\";out=1.add(2).split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("valid_array_bridges","Value:: I {return([num_add(1,2).split(\",\").first().cat(\"!\"),1.add(2).split(\",\").first().cat(\"!\")])}","x",JSON3.read("[\"3!\",\"3!\"]",Any))
    check("source_operand_snapshot","Value:: I {value=3;order=\"\";out=num_add({order=cat(order,\"S\");return(value)},{value=99;order=cat(order,\"O\");return(2)}).cat({order=cat(order,\"C\");\"!\"});return([out,value,order])}","x",JSON3.read("[\"5!\",99,\"SOC\"]",Any))
    check("zero_typed_indices","Value:: I {slots=[\"old\"];index=num_add(0,0).copy();slots[index]=\"free\";other=0.add(0).copy();slots[other]=\"receiver\";return([index,other,slots])}","x",JSON3.read("[0,0,[\"receiver\"]]",Any))
    check("valid_null_with","Value:: I {order=\"\";left=num_div(1,0).with(){order=cat(order,\"F\");return(\"free\")};right=1.div(0).with(){order=cat(order,\"R\");return(\"receiver\")};return([left,right,order])}","x",JSON3.read("[\"free\",\"receiver\",\"FR\"]",Any))
    check("valid_empty_with","Value:: I {order=\"\";out=num_div(1,0).coalesce([]).with(){order=cat(order,\"W\");return(value.count())};return([out,order])}","x",JSON3.read("[0,\"W\"]",Any))
    check("all_canonical_free_guards","Value:: I {order=\"\";out=[num_abs(-3).take({order=cat(order,\"A\");1}),num_floor(3.8).take({order=cat(order,\"A\");1}),num_ceil(3.2).take({order=cat(order,\"A\");1}),num_round(2.5).take({order=cat(order,\"A\");1}),num_add(1,2,3).take({order=cat(order,\"A\");1}),num_sub(5,2).take({order=cat(order,\"A\");1}),num_mul(2,3,4).take({order=cat(order,\"A\");1}),num_div(7,2).take({order=cat(order,\"A\");1}),num_mod(7,3).take({order=cat(order,\"A\");1}),num_clamp(12,0,10).take({order=cat(order,\"A\");1}),num_min(7,3,5).take({order=cat(order,\"A\");1}),num_max(3,5,4).take({order=cat(order,\"A\");1})];return([out,order])}","x",JSON3.read("[[null,null,null,null,null,null,null,null,null,null,null,null],\"\"]",Any))
    check("all_short_receiver_with_guards","Value:: I {order=\"\";out=[3.abs().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},3.8.floor().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},3.2.ceil().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},2.5.round().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},1.add(2,3).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},5.sub(2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},2.mul(3,4).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},7.div(2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},7.mod(3).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},12.clamp(0,10).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},7.min(3,5).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},3.max(5,4).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null,null,null,null,null,null,null,null,null],\"\"]",Any))
    check("function_scope","fn build(){order=\"\";left=num_add(1,2).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};right=1.add(2).take({order=cat(order,\"B\");1}).with(){order=cat(order,\"X\");return(\"ran\")};return([left,right,order])}\nValue:: I {value=\"caller\";return([build(),value])}","x",JSON3.read("[[null,null,\"\"],\"caller\"]",Any))
    actual=observe("Value:: I {return(num_add({items=\"text\";push(items,\"x\")},1).coalesce(\"masked\"))}","x")
    println("FREE_NUMERIC_ERROR ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for row in values(actual)
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    shapes=Any[]
    for source in (
        "num_abs().take(1).with(){return(\"x\")}",
        "num_add(1).take(1).with(){return(\"x\")}",
        "num_clamp(1,2).take(1)",
        "num_add(first:1,second:2).take(1)",
        "add(1,2).take(1)",
        "+(1,2).take(1)",
        "num_min([1,2]).take(1)",
        "[1,2].min().with(){return(value)}",
        "num_eq(1,1).take(1).with(){return(\"x\")}",
        "1.eq(1).take(1).with(){return(\"x\")}",
        "1.add().with(){return(\"x\")}",
        "1.add(2){return(\"x\")}",
        "{|| return(num_add(1,2).take(1)) }",
        "num_add(1,2).map_leaves(){return(value)}",
    )
        row=try
            Dict("source"=>source,"ast"=>to_json(parse_action_expression(source)))
        catch failure
            Dict("source"=>source,"error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
        end
        push!(shapes,row)
    end
    @test length(shapes)==14
    println("FREE_NUMERIC_SHAPES ",JSON3.write(shapes))
end
end # module
