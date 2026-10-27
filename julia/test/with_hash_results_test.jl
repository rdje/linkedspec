# TYPE-REFERENCE-BOOK.1.2.23.3.31.4 — ordinary eager with result composition.
function strict_with_result_equal(actual, expected)
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
            all(strict_with_result_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_with_result_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected with result fixture type $(typeof(expected))")
end
function with_result_routes(source, input)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    host = Module(gensym(:WithResultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "with-hash-results.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    return (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "plan" => () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), input, "with-hash-results.spec"),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
end
function check_with_results(source, input, expected)
    for (route, operation) in with_result_routes(source, input)
        actual = operation()
        println("WITH_RESULT ", route, " ", JSON3.write(actual))
        @test strict_with_result_equal(actual, expected)
    end
end
function with_result_action(action)
    return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {$action}\n"
end
@testset "Julia ordinary with results" begin
    @testset "Unchanged frozen Hash target" begin
        root = dirname(dirname(@__DIR__))
        source = read(joinpath(root, "tests", "fixtures", "with_hash_result_values.spec"), String)
        expected = JSON3.read(read(joinpath(root, "tests", "fixtures", "with_hash_result_values.json"), String), Any)
        check_with_results(source, "name=Alpha", expected)
    end
    @testset "Helper and receiver actual kinds skip incompatible operands" begin
        source = with_result_action(raw"""
order="";value="outer";
a={order=cat(order,"S");"source"}.with(){order=cat(order,"W");return(3)}.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
b="source".with(){return("text")}.take({order=cat(order,"A");1});
c="source".with(){return(["a","b"])}.last().uppercase();
d="source".with(){return(false)}.coalesce({order=cat(order,"F");true});
e="source".with(){return(null)}.coalesce({order=cat(order,"N");7}).add(1);
f=with("source"){return(3)}.set_key({order=cat(order,"J");"k"},{order=cat(order,"L");1});
g=with("source"){return("text")}.take({order=cat(order,"T");1});
return([a,b,c,d,e,f,g,order,value]);
""")
        check_with_results(source, "name=Alpha", Any[Any[nothing,nothing,"B",false,8,nothing,nothing,"SWN","outer"]])
    end
    @testset "Pure function scoped value" begin
        source = raw"""
fn pure(text){return(text.with(){return({"n":[value.uppercase()]})}.sorted_values().first().first())}
Top:: I {return(pure("ok"))}
"""
        check_with_results(source, "x", "OK")
    end
    @testset "Indexed specific function fence" begin
        source = raw"""
fn forbidden(){return("x".with(){return({"n":[entry_len()]})}.sorted_values().first()[0].uppercase())}
Top:: I {return(forbidden())}
"""
        for (route, operation) in with_result_routes(source, "x")
            error_text = try
                operation()
                ""
            catch failure
                sprint(showerror, failure)
            end
            @test occursin("parser-state helper", error_text) && occursin("entry_len", error_text)
        end
    end
end
