module JuliaReceiverStringBridgeGuards
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
    error("unexpected receiver String bridge fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:ReceiverBridgeGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "receiver-string-bridge-guards.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "receiver-string-bridge-guards.spec",
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
    println("RECEIVER_BRIDGE_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia receiver String-prefix bridge guards" begin
    check("reject_bridge_with","Value:: I {order=\"\";out=\" a,b \".trim().split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("reject_bridge_without_with","Value:: I {order=\"\";out=\" a,b \".trim().split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("source_once","Value:: I {order=\"\";out={order=cat(order,\"S\");return(\" a,b \")}.trim().split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"S\"]",Any))
    check("valid_selected_with","Value:: I {order=\"\";out=\" a,b \".trim().split(\",\").last().with(){order=cat(order,\"W\");return(value.uppercase())};return([out,order])}","x",JSON3.read("[\"B\",\"W\"]",Any))
    check("valid_empty_with","Value:: I {order=\"\";out=\"a\".trim().split(\",\").take(0).with(){order=cat(order,\"W\");return([value.count(),\"tail\"])};return([out,order])}","x",JSON3.read("[[0,\"tail\"],\"W\"]",Any))
    check("valid_null_with","Value:: I {order=\"\";out=\"\".trim().split(\",\").take(0).first().with(){order=cat(order,\"W\");return(\"recovered\")};return([out,order])}","x",JSON3.read("[\"recovered\",\"W\"]",Any))
    check("all_eight_prefixes","Value:: I {order=\"\";out=[\" a,b \".trim().split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"A,B\".lowercase().split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a,b\".uppercase().split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a-b\".replace_substr(\"-\",\",\").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"prefixa,b\".rm_prefix(\"prefix\").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a,bsuffix\".rm_suffix(\"suffix\").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a,b!\".substr(0,3).split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a\".cat(\",b\").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null,null,null,null,null],\"\"]",Any))
    check("function_scope","fn build(){order=\"\";out=\"a,b\".trim().split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}\nValue:: I {value=\"caller\";return([build(),value])}","x",JSON3.read("[[null,\"\"],\"caller\"]",Any))
    check("direct_rejection_with","Value:: I {order=\"\";out=\"tail\".trim().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("primitive_values","Value:: I {return([trim(\" tail \"),lowercase(\"TAIL\"),uppercase(\"tail\"),replace_substr(\"a-b\",\"-\",\",\"),rm_prefix(0,\"x\"),rm_suffix(false,\"x\"),substr(\"head\",1,2),cat(\"a\",\"b\")])}","x",JSON3.read("[\"tail\",\"tail\",\"TAIL\",\"a,b\",0,false,\"ea\",\"ab\"]",Any))
    check("compatible_values","Value:: I {return([trim(\" tail \").uppercase(),replace_substr(\"a-b\",\"-\",\",\").split(\",\").last().uppercase(),rm_prefix(0,\"x\").add(1),rm_suffix(false,\"x\").cat(\"!\")])}","x",JSON3.read("[\"TAIL\",\"B\",1,\"0!\"]",Any))
    check("receiver_numeric_identity_remains_an_array_index","Value:: I {slots=[\"old\"];index=0.rm_prefix(\"x\").copy();slots[index]=\"updated\";return([index,slots,false.rm_suffix(\"x\").copy()])}","x",JSON3.read("[0,[\"updated\"],false]",Any))
    actual=observe("Value:: I {return({items=\"text\";push(items,\"x\")}.trim().split(\",\").with(){return(\"masked\")})}","x")
    println("RECEIVER_BRIDGE_ERROR ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for row in values(actual)
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    shapes=Any[]
    for source in (
        "\"tail\".trim(\"extra\").split(\",\").set_key(\"k\",1).with(){return(\"x\")}",
        "\"tail\".cat().with(){return(\"x\")}",
        "\"tail\".substr(0,1,2).with(){return(\"x\")}",
        "\"tail\".trim(first:\"extra\").with(){return(\"x\")}",
        "\"tail\".custom_string().with(){return(\"x\")}",
        "\"tail\".trim().map_leaves(){return(value)}",
        "{|| return(\"tail\".trim().split(\",\").set_key(\"k\",1).with(){return(\"x\")}) }",
        "\"tail\".substr(/a/,\"x\",\"g\")",
        "\"tail\".trim(){return(\"x\")}",
    )
        row=try
            Dict("source"=>source,"ast"=>to_json(parse_action_expression(source)))
        catch failure
            Dict("source"=>source,"error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
        end
        push!(shapes,row)
    end
    @test length(shapes)==9
    println("RECEIVER_BRIDGE_SHAPES ",JSON3.write(shapes))
end
end # module
