# TYPE-REFERENCE-BOOK.1.2.23.3.32.4 — immediate contextual with-result reads.
function strict_with_selection_equal(actual, expected)
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
            all(strict_with_selection_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_with_selection_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected with result fixture type $(typeof(expected))")
end
function with_selection_routes(source, input)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    host = Module(gensym(:WithSelectionGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "with-result-selection.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    return (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "plan" => () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), input, "with-result-selection.spec"),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
end
function check_with_selection(source, input, expected)
    for (route, operation) in with_selection_routes(source, input)
        actual = operation()
        println("WITH_SELECTION_ACTUAL ", route, " ", JSON3.write(actual))
        @test strict_with_selection_equal(actual, expected)
    end
end

function observe_with_selection(source)
    try
        result = Dict{String, Any}()
        for (route, operation) in with_selection_routes(source, "x")
            result[route] = try
                Dict("ok" => operation())
            catch failure
                Dict("error" => sprint(showerror, failure))
            end
        end
        return result
    catch failure
        return Dict("compile_error" => sprint(showerror, failure))
    end
end
const with_selection_roles = [
"nested_pure" => raw"""fn pure(text){return(with(text){return([uppercase(value)])}[0])}
Top:: I {value="outer";nested=with("outside"){return(with("inside"){return([value])}[0])};return([nested,value,pure("ok")]);}""",
"bound_final" => raw"""Top:: I {order="";cb={|item|return([item])};return([with("z",cb)[0],with("z",cb)[9].count(),with("z",cb)[0].take({order=cat(order,"B");1}),order]);}""",
"literal_final" => raw"""Top:: I {return([with("z",{|item|return([item])})[0],with("z",{|item|return([item])})[9].count()]);}""",
"callback_bodies" => raw"""fn apply(callback: codeblock){return(callback())}
Top:: I {cb={||return(with("x"){return(["yes"])}[0])};a=apply(){return(with("x"){return(["yes"])}[0])};return([cb(),a,"x".with(){return([false])}[0].copy()]);}""",
"malformed_role" => raw"""Top:: I {return(with("x","extra"){return([1])}[0]);}""",
"missing_source" => raw"""Top:: I {return(with(missing_source()){return([1])}[0].uppercase())}""",
"missing_body" => raw"""Top:: I {return(with("x"){return([missing()])}[0].uppercase())}""",
"function_state" => raw"""fn forbidden(){return(with("x"){return([entry_len()])}[0].uppercase())}
Top:: I {return(forbidden())}""",
]
@testset "Julia immediate with selection" begin
    @testset "Frozen shared target" begin
        root = dirname(dirname(@__DIR__))
        source = read(joinpath(root, "tests", "fixtures", "with_result_selection_values.spec"), String)
        expected = JSON3.read(read(joinpath(root, "tests", "fixtures", "with_result_selection_values.json"), String), Any)
        check_with_selection(source, "x", expected)
    end

    @testset "Nested and pure scoped reads" begin
        check_with_selection(Dict(with_selection_roles)["nested_pure"], "x", Any["inside","outer","OK"])
    end
    @testset "Existing explicit and bound final consumer policies" begin
        check_with_selection(Dict(with_selection_roles)["bound_final"], "x", Any["z",0,Any[],"B"])
        check_with_selection(Dict(with_selection_roles)["literal_final"], "x", Any["z",0])
    end
    @testset "Existing callable and registered callback body reads" begin
        check_with_selection(Dict(with_selection_roles)["callback_bodies"], "x", Any["yes","yes",false])
    end
    @testset "Malformed contextual arity" begin
        result = observe_with_selection(Dict(with_selection_roles)["malformed_role"])
        println("WITH_SELECTION_ARITY ", JSON3.write(result))
        @test Set(keys(result)) == Set(["compile_error"]) && all(
            occursin(part, result["compile_error"]) for part in
            ("callable_contract_arity_mismatch", "helper 'with'", "got 2")
        )
    end
    @testset "Existing specific source body and function error owners" begin
        for (name, required) in [
            "function_state" => ["parser-state helper", "entry_len"],
            "missing_source" => ["unsupported runtime helper", "missing_source"],
            "missing_body" => ["unknown_helper", "name=\"missing\""],
        ]
            result = observe_with_selection(Dict(with_selection_roles)[name])
            println("WITH_SELECTION_ERROR ", name, " ", JSON3.write(result))
            @test Set(keys(result)) == Set(["native","plan","fresh"])
            for route in ("native","plan","fresh")
                row = get(result, route, Dict{String,Any}())
                @test haskey(row, "error") && all(occursin(part, row["error"]) for part in required)
            end
        end
    end
    @testset "Legacy bound-call selected result policy" begin
        check_with_selection(raw"""Top:: I {
            thunk={|| return([false,["tail"]])};
            return([thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count()]);
        }""", "x", Any[false,"TAIL",0,0])
    end
end
