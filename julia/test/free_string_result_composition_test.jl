module JuliaFreeStringResultComposition
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
    error("unexpected free String fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:FreeStringGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "free-string-result-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "free-string-result-composition.spec",
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
    println("FREE_STRING_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia canonical free String result guards" begin
    check("primitive_values","Value:: I {return([trim(\" tail \"),lowercase(\"TAIL\"),uppercase(\"tail\"),replace_substr(\"a-b\",\"-\",\",\"),rm_prefix(0,\"x\"),rm_suffix(false,\"x\"),substr(\"head\",1,2),cat(\"a\",\"b\")])}","x",JSON3.read("[\"tail\",\"tail\",\"TAIL\",\"a,b\",0,false,\"ea\",\"ab\"]",Any))
    check("compatible_values","Value:: I {return([trim(\" tail \").uppercase(),replace_substr(\"a-b\",\"-\",\",\").split(\",\").last().uppercase(),rm_prefix(0,\"x\").add(1),rm_suffix(false,\"x\").cat(\"!\")])}","x",JSON3.read("[\"TAIL\",\"B\",1,\"0!\"]",Any))
    check("free_container_guards","Value:: I {order=\"\";left=trim(\"tail\").take({order=cat(order,\"A\");1});right=uppercase(\"tail\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("receiver_container_guards","Value:: I {order=\"\";left=\"tail\".trim().take({order=cat(order,\"A\");1});right=\"tail\".uppercase().set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("bound_guarded_bridge","Value:: I {order=\"\";saved=trim(\"tail\");out=saved.coalesce(undef).take({order=cat(order,\"A\");1});return([out,saved,order])}","x",JSON3.read("[null,\"tail\",\"\"]",Any))
    check("valid_null_with","Value:: I {order=\"\";out=trim(undef).with(){order=cat(order,\"W\");return(\"recovered\")};return([out,order])}","x",JSON3.read("[\"recovered\",\"W\"]",Any))
    check("guard_before_with","Value:: I {order=\"\";out=trim({order=cat(order,\"S\");return(\"tail\")}).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"S\"]",Any))
    check("source_order_snapshot","Value:: I {value=\" tail \";order=\"\";out=replace_substr({order=cat(order,\"S\");return(value)},{value=\"other\";order=cat(order,\"O\");\" \"},{order=cat(order,\"N\");\"_\"}).cat({order=cat(order,\"C\");\"!\"});return([out,value,order])}","x",JSON3.read("[\"_tail_!\",\"other\",\"SONC\"]",Any))
    check("all_free_guard_sources","Value:: I {order=\"\";out=[trim(\"tail\").take({order=cat(order,\"A\");1}),lowercase(\"TAIL\").take({order=cat(order,\"A\");1}),uppercase(\"tail\").take({order=cat(order,\"A\");1}),replace_substr(\"a-b\",\"-\",\",\").take({order=cat(order,\"A\");1}),rm_prefix(0,\"x\").take({order=cat(order,\"A\");1}),rm_suffix(false,\"x\").take({order=cat(order,\"A\");1}),substr(\"tail\",0,1).take({order=cat(order,\"A\");1}),cat(\"t\",\"ail\").take({order=cat(order,\"A\");1})];return([out,order])}","x",JSON3.read("[[null,null,null,null,null,null,null,null],\"\"]",Any))
    check("function_scope","fn build(){order=\"\";out=trim(\"tail\").take({order=cat(order,\"A\");1});return([out,order])}\nValue:: I {value=\"caller\";return([build(),value])}","x",JSON3.read("[[null,\"\"],\"caller\"]",Any))
    check("free_bridge_rejection","Value:: I {order=\"\";out=trim(\" a,b \").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("valid_empty_bridge_with","Value:: I {order=\"\";out=trim(\" a,b \").split(\",\").take(0).with(){order=cat(order,\"W\");return([value.count(),\"tail\"])};return([out,order])}","x",JSON3.read("[[0,\"tail\"],\"W\"]",Any))
    check("valid_null_after_bridge_with","Value:: I {order=\"\";out=trim(\"\").split(\",\").take(0).first().with(){order=cat(order,\"W\");return(\"recovered\")};return([out,order])}","x",JSON3.read("[\"recovered\",\"W\"]",Any))
    check("legacy_named_empty_fallback","Value:: I {items=\"text\";return([take(items,1),sorted_values(items)])}","x",JSON3.read("[[],[]]",Any))
    check("numeric_identity_remains_an_array_index","Value:: I {slots=[\"old\"];index=rm_prefix(0,\"x\").copy();slots[index]=\"updated\";return([index,slots,rm_suffix(false,\"x\").copy()])}","x",JSON3.read("[0,[\"updated\"],false]",Any))
    actual=observe("Value:: I {return(trim({items=\"text\";push(items,\"x\")}).coalesce(\"masked\"))}","x")
    println("FREE_STRING_ERROR ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for row in values(actual)
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    actual=observe("Value:: I {order=\"\";out=\" a,b \".trim().split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x")
    println("FREE_STRING_CONTEXT ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for row in values(actual)
        @test row==actual["native"]
    end
    shapes=Any[]
    for source in (
        "trim().take(1)",
        "trim(\"tail\",\"extra\").take(1)",
        "cat(\"tail\").take(1)",
        "cat().take(1)",
        "substr(\"tail\",0,1,\"g\").take(1)",
        "trim(first:\"tail\").take(1)",
        "trim(\"tail\"){return(\"x\")}.take(1)",
        "custom_string(\"tail\").take(1)",
        "{|| return(trim(\"tail\").take(1)) }",
    )
        row=try
            Dict("source"=>source,"ast"=>to_json(parse_action_expression(source)))
        catch failure
            Dict("source"=>source,"error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
        end
        push!(shapes,row)
    end
    @test length(shapes)==9
    println("FREE_STRING_SHAPES ",JSON3.write(shapes))
end
end # module
