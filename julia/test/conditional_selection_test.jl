# TYPE-REFERENCE-BOOK.1.2.23.3.26.4 — inline conditional result selection.
function strict_conditional_selection_equal(actual, expected)
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
            all(strict_conditional_selection_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_conditional_selection_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected conditional fixture type $(typeof(expected))")
end

function check_conditional_selection(source, expected)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    host = Module(gensym(:ConditionalSelectionGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "conditional-selection.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    observations = Pair{String,Any}[]
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value,
        "plan" => () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), "x", "conditional-selection.spec"),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"),
    )
        actual = try
            operation()
        catch error
            Dict("unexpected_error" => sprint(showerror, error))
        end
        push!(observations, route => actual)
    end
    println("CONDITIONAL_SELECTION_OBSERVATIONS ", JSON3.write(Dict(observations)))
    for (route, actual) in observations
        @testset "$route" begin
            @test strict_conditional_selection_equal(actual, expected)
        end
    end
end

@testset "Julia inline conditional selection" begin
    @testset "Unchanged frozen target" begin
        root = dirname(dirname(@__DIR__))
        source = read(joinpath(root,"tests","fixtures","conditional_selection_values.spec"),String)
        expected = JSON3.read(read(joinpath(root,"tests","fixtures","conditional_selection_values.json"),String),Any)
        check_conditional_selection(source, expected)
    end
    @testset "With rejects incompatible operands" begin
        check_conditional_selection(raw"""Top:: I {
 order="";
 a=if(true,[false],[])[0].with() {return(value)}.take({order=cat(order,"A");1});
 b=switch("k",case("k",[[1]]))[0].set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});
 return([a,b,order]);
}""", Any[nothing,nothing,""])
    end
    @testset "Lazy order and block local return" begin
        check_conditional_selection(raw"""Top:: I {
 order="";
 selected=if({order=cat(order,"C");false},["bad"],
  elseif({order=cat(order,"E");true},{order=cat(order,"T");return([{"items":["a","b"]}]);order="bad"}),
  else({order=cat(order,"F");["bad"]}))[0]["items"][-1].uppercase().cat({order=cat(order,"M");"!"});
 return([selected,order]);
}""", Any["B!","CETM"])
    end
    @testset "Missing inline versus legacy header alias bound flat counts" begin
        check_conditional_selection(raw"""Top:: I {
 thunk={|| return([false,["tail"]])};
 return([if(false,[1])[0].count(),switch("other",case("k",[1]))[0].count(),thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count(),if(true)[0].count(),switch("k")[0].count(),flat([1])[9].count(),i(false,[1])[0].count()]);
}""", Any[nothing,nothing,false,"TAIL",0,0,0,0,0,0])
    end
    @testset "Parsed source roles" begin
        value = parse_action_expression("if(true,[1],[])[0]")
        @test value.receiver.name == "if"
        @test length(value.receiver.args) == 3
        @test !value.receiver.trailing_block_arg
        header = parse_action_expression("if(true)[0]")
        @test length(header.receiver.args) == 1
        alias = parse_action_expression("i(false,[1])[0]")
        @test something(alias.receiver.source_method, alias.receiver.name) == "i"
        attached = parse_action_expression("if(true) {return([1])}[0]")
        @test attached.receiver.trailing_block_arg
    end
end
