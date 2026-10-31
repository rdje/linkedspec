module JuliaPresenceResultGuardComposition
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
    error("unexpected has_key source fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:PresenceGuardGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "presence-result-guard-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "presence-result-guard-composition.spec",
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
    println("PRESENCE_GUARD_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia has_key source and prefix guards" begin
    check("primitive_presence","Value:: I {return([has_key({\"k\":false},\"k\"),has_key({},\"k\"),has_key({\"k\":undef},\"k\"),{\"k\":1}.has_key(\"k\"),{}.has_key(\"k\")])}","x",JSON3.read("[1,0,1,1,0]",Any))
    check("free_container_guards","Value:: I {order=\"\";left=has_key({},\"k\").take({order=cat(order,\"A\");1});right=has_key({\"k\":1},\"k\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("receiver_container_guards","Value:: I {order=\"\";left={}.has_key(\"k\").take({order=cat(order,\"A\");1});right={\"k\":1}.has_key(\"k\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("free_guard_before_with","Value:: I {order=\"\";out=has_key({order=cat(order,\"S\");{}},{order=cat(order,\"K\");\"k\"}).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"SK\"]",Any))
    check("receiver_guard_before_with","Value:: I {order=\"\";out={order=cat(order,\"S\");{}}.has_key({order=cat(order,\"K\");\"k\"}).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"SK\"]",Any))
    check("free_bridge_rejection","Value:: I {order=\"\";out=has_key({},\"k\").cat(\"x\").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("receiver_bridge_rejection","Value:: I {order=\"\";out={}.has_key(\"k\").cat(\"x\").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("compatible_values","Value:: I {return([has_key({},\"k\").cat(\"!\"),has_key({},\"k\").coalesce_nonempty(\"late\").cat(\"!\"),{}.has_key(\"k\").coalesce(\"late\").cat(\"!\")])}","x",JSON3.read("[\"0!\",\"0!\",\"0!\"]",Any))
    check("value_kinds","Value:: I {return([has_key({},\"k\").copy(),{}.has_key(\"k\").copy(),has_key({},\"k\").add(1),has_key({\"k\":1},\"k\").add(1)])}","x",JSON3.read("[0,0,1,2]",Any))
    check("source_key_snapshot","Value:: I {order=\"\";meta={};out=has_key({order=cat(order,\"S\");meta},{order=cat(order,\"K\");meta[\"k\"]=1;\"k\"}).cat({order=cat(order,\"C\");meta[\"k\"]=2;\"!\"});return([out,meta,order])}","x",JSON3.read("[\"0!\",{\"k\":2},\"SKC\"]",Any))
    check("valid_false_with","Value:: I {order=\"\";out=has_key({},\"k\").with(){order=cat(order,\"W\");return([value,value.copy()])};return([out,order])}","x",JSON3.read("[[0,0],\"W\"]",Any))
    check("null_source_key_effect","Value:: I {order=\"\";out=has_key(undef,{order=cat(order,\"K\");\"k\"}).cat(\"!\");return([out,order])}","x",JSON3.read("[\"0!\",\"K\"]",Any))
    check("valid_array_bridges","Value:: I {return([has_key({},\"k\").cat(\",x\").split(\",\").last().uppercase(),{\"k\":1}.has_key(\"k\").cat(\",x\").split(\",\").last().uppercase()])}","x",JSON3.read("[\"X\",\"X\"]",Any))
    check("valid_null_with","Value:: I {order=\"\";left=has_key({},\"k\").add(\"bad\").with(){order=cat(order,\"F\");return(\"free\")};right={}.has_key(\"k\").add(\"bad\").with(){order=cat(order,\"R\");return(\"receiver\")};return([left,right,order])}","x",JSON3.read("[\"free\",\"receiver\",\"FR\"]",Any))
    check("valid_empty_with","Value:: I {order=\"\";out=has_key({},\"k\").add(\"bad\").coalesce([]).with(){order=cat(order,\"W\");return(value.count())};return([out,order])}","x",JSON3.read("[0,\"W\"]",Any))
    check("with_result_array","Value:: I {order=\"\";out=has_key({},\"k\").with(){order=cat(order,\"W\");return([\"ok\"])}.first().uppercase();return([out,order])}","x",JSON3.read("[\"OK\",\"W\"]",Any))
    check("function_scope","fn build(){order=\"\";left=has_key({},\"k\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};right={\"k\":1}.has_key(\"k\").take({order=cat(order,\"B\");1}).with(){order=cat(order,\"X\");return(\"ran\")};return([left,right,order])}\nValue:: I {value=\"caller\";return([build(),value])}","x",JSON3.read("[[null,null,\"\"],\"caller\"]",Any))
    check("all_canonical_free_with_guards","Value:: I {order=\"\";out=[has_key({},\"k\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},has_key({\"k\":1},\"k\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},has_key({\"k\":false},\"k\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},has_key({\"k\":undef},\"k\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null],\"\"]",Any))
    check("all_short_receiver_with_guards","Value:: I {order=\"\";out=[{}.has_key(\"k\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},{\"k\":1}.has_key(\"k\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},{\"k\":false}.has_key(\"k\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},{\"k\":undef}.has_key(\"k\").take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null],\"\"]",Any))
    check("all_canonical_free_guards","Value:: I {order=\"\";out=[has_key({},\"k\").take({order=cat(order,\"A\");1}),has_key({\"k\":1},\"k\").take({order=cat(order,\"A\");1}),has_key({\"k\":false},\"k\").take({order=cat(order,\"A\");1}),has_key({\"k\":undef},\"k\").take({order=cat(order,\"A\");1})];return([out,order])}","x",JSON3.read("[[null,null,null,null],\"\"]",Any))
    check("repeated_predicates","Value:: I {return([has_key({},\"k\").is_empty().cat(\"!\"),has_key({},\"k\").is_defined().cat(\"!\"),{}.has_key(\"k\").is_nonempty().cat(\"!\"),{\"k\":1}.has_key(\"k\").is_undefined().cat(\"!\")])}","x",JSON3.read("[\"0!\",\"1!\",\"1!\",\"0!\"]",Any))
    fixture_root=dirname(dirname(@__DIR__))
    check("null_source_operand_snapshot",
        read(joinpath(fixture_root,"tests","fixtures","has_key_null_source_operand_values.spec"),String),
        "x",JSON3.read(read(joinpath(fixture_root,"tests","fixtures","has_key_null_source_operand_values.perl.json"),String),Any))
    actual=observe("Value:: I {return(has_key({items=\"text\";push(items,\"x\")},\"k\").coalesce(\"masked\"))}","x")
    println("PRESENCE_GUARD_ERROR needed_source_error ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for (route,row) in actual
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    shapes=Any[]
    for source in (
        "has_key().take(1).with(){return(\"x\")}",
        "has_key({}).take(1)",
        "has_key({},\"k\",\"x\").take(1)",
        "has_key(source:{},key:\"k\").take(1)",
        "{}.has_key().with(){return(\"x\")}",
        "{}.has_key(\"k\",\"x\").with(){return(\"x\")}",
        "{}.has_key(key:\"k\").with(){return(\"x\")}",
        "has_key({},key:\"k\").take(1)",
        "has_key({},\"k\"){return(\"x\")}",
        "{}.has_key(\"k\"){return(\"x\")}",
        "has_key({},\"k\").map_leaves(){return(value)}",
        "{}.has_key(\"k\").map_leaves(){return(value)}",
        "{|| return(has_key({},\"k\").take(1).with(){return(\"x\")}) }",
        "has_key({},\"k\").custom_presence().with(){return(\"x\")}",
        "{}.has_key(\"k\").custom_presence().with(){return(\"x\")}",
        "is_empty([]).take(1).with(){return(\"x\")}",
        "is_defined(undef).take(1).with(){return(\"x\")}",
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
    println("PRESENCE_GUARD_SHAPES ",JSON3.write(shapes))
end
end # module
