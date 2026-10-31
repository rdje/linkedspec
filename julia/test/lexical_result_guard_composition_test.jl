module JuliaLexicalResultGuardComposition
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
    host = Module(gensym(:LexicalGuardGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "lexical-result-guard-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "lexical-result-guard-composition.spec",
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
    println("LEXICAL_GUARD_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia lexical source and prefix guards" begin
    check("primitive_comparisons","Value:: I {return([[str_eq(\"a\",\"a\"),str_ne(\"a\",\"b\"),str_gt(\"b\",\"a\"),str_ge(\"a\",\"a\"),str_lt(\"a\",\"b\"),str_le(\"a\",\"a\"),str_eq(\"a\",\"b\"),str_ne(\"a\",\"a\"),str_gt(\"a\",\"b\"),str_ge(\"a\",\"b\"),str_lt(\"b\",\"a\"),str_le(\"b\",\"a\")],[\"a\".str_eq(\"a\"),\"a\".str_ne(\"b\"),\"b\".str_gt(\"a\"),\"a\".str_ge(\"a\"),\"a\".str_lt(\"b\"),\"a\".str_le(\"a\"),\"a\".str_eq(\"b\"),\"a\".str_ne(\"a\"),\"a\".str_gt(\"b\"),\"a\".str_ge(\"b\"),\"b\".str_lt(\"a\"),\"b\".str_le(\"a\")]])}","x",JSON3.read("[[true,true,true,true,true,true,false,false,false,false,false,false],[true,true,true,true,true,true,false,false,false,false,false,false]]",Any))
    check("compatible_values","Value:: I {return([str_eq(\"a\",\"a\").cat(\"!\"),str_eq(\"a\",\"b\").coalesce_nonempty(9).cat(\"!\"),str_lt(\"a\",\"b\").cat(\",tail\").split(\",\").last().uppercase(),\"a\".str_eq(\"b\").cat(\"!\")])}","x",JSON3.read("[\"1!\",\"0!\",\"TAIL\",\"0!\"]",Any))
    check("value_kinds","Value:: I {return([str_eq(\"a\",\"b\").copy(),\"a\".str_eq(\"b\").copy(),str_eq(\"a\",\"b\").add(1),\"a\".str_eq(\"a\").add(1)])}","x",JSON3.read("[false,false,null,null]",Any))
    check("free_container_guards","Value:: I {order=\"\";left=str_eq(\"a\",\"b\").take({order=cat(order,\"A\");1});right=str_gt(\"b\",\"a\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("receiver_container_guards","Value:: I {order=\"\";left=\"a\".str_eq(\"b\").take({order=cat(order,\"A\");1});right=\"b\".str_gt(\"a\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("free_guard_before_with","Value:: I {order=\"\";out=str_eq({order=cat(order,\"S\");return(\"a\")},{order=cat(order,\"O\");return(\"b\")}).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"SO\"]",Any))
    check("receiver_guard_before_with","Value:: I {order=\"\";out={order=cat(order,\"S\");return(\"a\")}.str_eq({order=cat(order,\"O\");return(\"b\")}).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"SO\"]",Any))
    check("free_bridge_rejection","Value:: I {order=\"\";out=str_eq(\"a\",\"b\").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("receiver_bridge_rejection","Value:: I {order=\"\";out=\"a\".str_eq(\"b\").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("valid_array_bridges","Value:: I {return([str_eq(\"a\",\"b\").split(\",\").first().cat(\"!\"),\"a\".str_eq(\"a\").split(\",\").first().cat(\"!\")])}","x",JSON3.read("[\"0!\",\"1!\"]",Any))
    check("source_operand_snapshot","Value:: I {word=\"a\";order=\"\";out=str_eq({order=cat(order,\"S\");return(word)},{word=\"zzz\";order=cat(order,\"O\");return(\"b\")}).cat({order=cat(order,\"C\");\"!\"});return([out,word,order])}","x",JSON3.read("[\"0!\",\"zzz\",\"SOC\"]",Any))
    check("valid_false_and_true_with","Value:: I {order=\"\";left=str_eq(\"a\",\"b\").with(){order=cat(order,\"F\");return([value,value.copy()])};right=\"a\".str_eq(\"a\").with(){order=cat(order,\"R\");return(value)};return([left,right,order])}","x",JSON3.read("[[false,false],true,\"FR\"]",Any))
    check("valid_null_with","Value:: I {order=\"\";left=str_eq(\"a\",\"a\").add(\"bad\").with(){order=cat(order,\"F\");return(\"free\")};right=\"a\".str_eq(\"a\").add(\"bad\").with(){order=cat(order,\"R\");return(\"receiver\")};return([left,right,order])}","x",JSON3.read("[\"free\",\"receiver\",\"FR\"]",Any))
    check("valid_empty_with","Value:: I {order=\"\";out=str_eq(\"a\",\"b\").add(\"bad\").coalesce([]).with(){order=cat(order,\"W\");return(value.count())};return([out,order])}","x",JSON3.read("[0,\"W\"]",Any))
    check("with_result_array","Value:: I {order=\"\";out=str_eq(\"a\",\"b\").with(){order=cat(order,\"W\");return([\"ok\"])}.first().uppercase();return([out,order])}","x",JSON3.read("[\"OK\",\"W\"]",Any))
    check("all_canonical_free_with_guards","Value:: I {order=\"\";out=[str_eq(\"a\",\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},str_ne(\"a\",\"b\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},str_gt(\"b\",\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},str_ge(\"a\",\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},str_lt(\"a\",\"b\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},str_le(\"a\",\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},str_eq(\"a\",\"b\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},str_ne(\"a\",\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},str_gt(\"a\",\"b\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},str_ge(\"a\",\"b\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},str_lt(\"b\",\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},str_le(\"b\",\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null,null,null,null,null,null,null,null,null],\"\"]",Any))
    check("all_short_receiver_with_guards","Value:: I {order=\"\";out=[\"a\".str_eq(\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a\".str_ne(\"b\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"b\".str_gt(\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a\".str_ge(\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a\".str_lt(\"b\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a\".str_le(\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a\".str_eq(\"b\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a\".str_ne(\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a\".str_gt(\"b\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"a\".str_ge(\"b\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"b\".str_lt(\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},\"b\".str_le(\"a\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null,null,null,null,null,null,null,null,null],\"\"]",Any))
    check("function_scope","fn build(){order=\"\";left=str_eq(\"a\",\"b\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};right=\"a\".str_eq(\"a\").take({order=cat(order,\"B\");1}).with(){order=cat(order,\"X\");return(\"ran\")};return([left,right,order])}\nValue:: I {value=\"caller\";return([build(),value])}","x",JSON3.read("[[null,null,\"\"],\"caller\"]",Any))
    check("all_canonical_free_guards","Value:: I {order=\"\";out=[str_eq(\"a\",\"a\").take({order=cat(order,\"A\");1}),str_ne(\"a\",\"b\").take({order=cat(order,\"A\");1}),str_gt(\"b\",\"a\").take({order=cat(order,\"A\");1}),str_ge(\"a\",\"a\").take({order=cat(order,\"A\");1}),str_lt(\"a\",\"b\").take({order=cat(order,\"A\");1}),str_le(\"a\",\"a\").take({order=cat(order,\"A\");1}),str_eq(\"a\",\"b\").take({order=cat(order,\"A\");1}),str_ne(\"a\",\"a\").take({order=cat(order,\"A\");1}),str_gt(\"a\",\"b\").take({order=cat(order,\"A\");1}),str_ge(\"a\",\"b\").take({order=cat(order,\"A\");1}),str_lt(\"b\",\"a\").take({order=cat(order,\"A\");1}),str_le(\"b\",\"a\").take({order=cat(order,\"A\");1})];return([out,order])}","x",JSON3.read("[[null,null,null,null,null,null,null,null,null,null,null,null],\"\"]",Any))
    actual=observe("Value:: I {return(str_eq({items=\"text\";push(items,\"x\")},\"a\").coalesce(\"masked\"))}","x")
    println("LEXICAL_GUARD_ERROR needed_source_error ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for (route,row) in actual
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    shapes=Any[]
    for source in (
        "str_eq().take(1).with(){return(\"x\")}",
        "str_eq(\"a\").take(1).with(){return(\"x\")}",
        "str_eq(\"a\",\"a\",\"a\").take(1)",
        "str_eq(left:\"a\",right:\"a\").take(1)",
        "eq(\"a\",\"a\").take(1)",
        "==(\"a\",\"a\").take(1)",
        "num_eq(1,1).take(1).with(){return(\"x\")}",
        "and(false).take(1).with(){return(\"x\")}",
        "\"a\".str_eq().with(){return(\"x\")}",
        "\"a\".str_eq(\"a\",\"a\").with(){return(\"x\")}",
        "\"a\".str_eq(right:\"a\").with(){return(\"x\")}",
        "str_eq(\"a\",\"a\"){return(\"x\")}",
        "\"a\".str_eq(\"a\"){return(\"x\")}",
        "str_eq(\"a\",\"a\").map_leaves(){return(value)}",
        "\"a\".str_eq(\"a\").map_leaves(){return(value)}",
        "{|| return(str_eq(\"a\",\"a\").take(1).with(){return(\"x\")}) }",
        "str_eq(\"a\",\"a\").custom_compare().with(){return(\"x\")}",
        "\"a\".str_eq(\"a\").custom_compare().with(){return(\"x\")}",
    )
        row=try
            Dict("source"=>source,"ast"=>to_json(parse_action_expression(source)))
        catch failure
            Dict("source"=>source,"error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
        end
        push!(shapes,row)
    end
    @test length(shapes)==18
    println("LEXICAL_GUARD_SHAPES ",JSON3.write(shapes))
end
end # module
