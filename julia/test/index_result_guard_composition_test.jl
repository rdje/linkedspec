module JuliaIndexGuardComposition
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
    error("unexpected index fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:IndexGuardGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "index-result-guard-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "index-result-guard-composition.spec",
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
    println("INDEX_GUARD_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia index source and prefix guards" begin
    fixture_root=dirname(dirname(@__DIR__))
    cases=JSON3.read(read(joinpath(fixture_root,"tests","fixtures","index_result_guard_cases.json"),String),Any)
    append!(cases,JSON3.read(read(joinpath(fixture_root,"tests","fixtures","index_null_prefix_guard_cases.json"),String),Any))
    append!(cases,JSON3.read(read(joinpath(fixture_root,"tests","fixtures","index_null_with_guard_cases.json"),String),Any))
    for row in cases
        if haskey(row,"expected_error")
            actual=observe(row["source"],row["input"])
            println("INDEX_GUARD_ERROR ",row["id"]," ",JSON3.write(actual))
            @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
            for (route,value) in actual
                @test occursin(row["expected_error"],get(value,"error",""))
            end
        else
            expected=get(row,"expected_nonperl",row["expected"])
            check(row["id"],row["source"],row["input"],expected)
        end
    end
    shapes=Any[]
    rows=JSON3.read(read(joinpath(fixture_root,"tests","fixtures","index_result_guard_excluded_ast.json"),String),Any)
    for input in rows
        source=input["source"]
        row=try
            Dict("source"=>source,"ast"=>to_json(parse_action_expression(source)))
        catch failure
            Dict("source"=>source,"error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
        end
        push!(shapes,row)
    end
    @test length(shapes)==18
    println("INDEX_GUARD_SHAPES ",JSON3.write(shapes))
end
end # module
