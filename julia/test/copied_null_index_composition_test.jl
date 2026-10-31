module JuliaCopiedNullIndexComposition
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
    error("unexpected index source fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:CopiedNullIndexGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "copied-null-index-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "copied-null-index-composition.spec",
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
    println("COPIED_NULL_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia copied-null index composition" begin
    fixture_root=dirname(dirname(@__DIR__))
    cases=JSON3.read(read(joinpath(fixture_root,"tests","fixtures","copied_null_index_cases.json"),String),Any)
    append!(cases,JSON3.read("[{\"id\":\"copied_null_needle_policy\",\"body\":\"order=\\\"\\\";out=[{undef}.copy().index_of({order=cat(order,\\\"A\\\");\\\"a\\\"}),copy({undef}).index_of({order=cat(order,\\\"B\\\");\\\"a\\\"}),index_of(copy({undef}),{order=cat(order,\\\"C\\\");\\\"a\\\"})];return([out,order])\",\"source\":\"Value:: I {order=\\\"\\\";out=[{undef}.copy().index_of({order=cat(order,\\\"A\\\");\\\"a\\\"}),copy({undef}).index_of({order=cat(order,\\\"B\\\");\\\"a\\\"}),index_of(copy({undef}),{order=cat(order,\\\"C\\\");\\\"a\\\"})];return([out,order])}\",\"rule\":\"Value\",\"input\":\"x\",\"input_characters\":1,\"leading_codepoint\":120,\"component\":\"null_diagnostic\",\"observation_only\":true,\"expected\":[[null,null,null],\"ABC\"]},{\"id\":\"null_source_needle_policy\",\"body\":\"order=\\\"\\\";out=[index_of(undef,{order=cat(order,\\\"F\\\");\\\"a\\\"}),{undef}.index_of({order=cat(order,\\\"R\\\");\\\"a\\\"}),[].first().index_of({order=cat(order,\\\"S\\\");\\\"a\\\"})];return([out,order])\",\"source\":\"Value:: I {order=\\\"\\\";out=[index_of(undef,{order=cat(order,\\\"F\\\");\\\"a\\\"}),{undef}.index_of({order=cat(order,\\\"R\\\");\\\"a\\\"}),[].first().index_of({order=cat(order,\\\"S\\\");\\\"a\\\"})];return([out,order])}\",\"rule\":\"Value\",\"input\":\"x\",\"input_characters\":1,\"leading_codepoint\":120,\"component\":\"null_diagnostic\",\"observation_only\":true,\"expected\":[[null,null,null],\"FRS\"]}]",Any))
    for row in cases
        if haskey(row,"expected_error")
            actual=observe(row["source"],row["input"])
            println("COPIED_NULL_ERROR ",row["id"]," ",JSON3.write(actual))
            @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
            for (route,value) in actual
                @test occursin(row["expected_error"],get(value,"error",""))
            end
        else
            check(row["id"],row["source"],row["input"],row["expected"])
        end
    end
end
end # module
