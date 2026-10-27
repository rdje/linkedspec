# TYPE-REFERENCE-BOOK.1.2.1.4.2.2.4 — ADR0138 value copying.
function strict_copy_equal(actual, expected)
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
            all(strict_copy_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_copy_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected fixture type $(typeof(expected))")
end

function check_value_copy(source, expected; input="x")
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    host = Module(gensym(:ValueCopyGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "value-copy.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    observations = Pair{String,Any}[]
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "plan" => () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), input, "value-copy.spec"),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
        actual = try
            operation()
        catch error
            Dict("unexpected_error" => sprint(showerror, error))
        end
        push!(observations, route => actual)
    end
    println("COPY_OBSERVATIONS ", JSON3.write(Dict(observations)))
    for (route, actual) in observations
        @testset "$route" begin
            @test strict_copy_equal(actual, expected)
        end
    end
end

@testset "Julia value-copy contract" begin
@testset "Primitive value-copy kinds sources scopes and continuations" begin
    root = dirname(dirname(@__DIR__))
    source = read(joinpath(root,"tests","fixtures","value_copy_values.spec"),String)
    expected = JSON3.read(read(joinpath(root,"tests","fixtures","value_copy_values.json"),String),Any)
    check_value_copy(source,expected)
end

@testset "Copied containers check kind before operands" begin
    check_value_copy(raw"""Top:: I {
        order="";
        a=copy({"a":1}).take({order=cat(order,"A");1});
        b=copy([1]).set_key({order=cat(order,"K");"a"},{order=cat(order,"V");2});
        return([a,b,order]);
    }""", Any[nothing,nothing,""])
end

@testset "Copy method shape precedes source and operands" begin
    check_value_copy(raw"""Top:: I {
        order="";
        a={order=cat(order,"S");false}.copy({order=cat(order,"A");1});
        b={order=cat(order,"R");[1]}.copy(fail("must-not-run"));
        return([a,b,order]);
    }""", Any[nothing,nothing,""])
end

@testset "Legacy accumulator and String payload stay distinct" begin
    check_value_copy("Top::\n -> Item .push\n LX.return([copy(Top),copy(\"Top\")])\n\nItem: /x/ I.return(\"x\")\n",
        Any[Any["x","x"],"Top"];input="xx")
end
end
