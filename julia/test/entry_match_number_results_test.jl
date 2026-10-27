# TYPE-REFERENCE-BOOK.1.2.23.3.30.4 — frozen Number reader composition.
function strict_entry_number_equal(actual, expected)
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
            all(strict_entry_number_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_entry_number_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected Number fixture type $(typeof(expected))")
end
function entry_number_routes(source, input)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    host = Module(gensym(:EntryNumberGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "entry-match-number-results.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    return (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "plan" => () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), input, "entry-match-number-results.spec"),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
end
function check_entry_numbers(source, input, expected)
    for (route, operation) in entry_number_routes(source, input)
        actual = operation()
        println("NUMBER_READER ", route, " ", JSON3.write(actual))
        @test strict_entry_number_equal(actual, expected)
    end
end
function entry_number_action(action)
    return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {$action}\n"
end
@testset "Julia entry match Number results" begin
    @testset "Unchanged frozen target" begin
        root = dirname(dirname(@__DIR__))
        source = read(joinpath(root, "tests", "fixtures", "entry_match_number_result_values.spec"), String)
        expected = JSON3.read(read(joinpath(root, "tests", "fixtures", "entry_match_number_result_values.json"), String), Any)
        check_entry_numbers(source, "name=Alpha", expected)
    end
    @testset "Absent match lazy fallback" begin
        check_entry_numbers("Top:: I {order=\"\";return([match_len().coalesce({order=cat(order,\"F\");7}).add(1),order])}", "x", Any[8, "F"])
    end
    @testset "Specific function fence" begin
        source = "fn forbidden(){return(entry_len())}\nTop:: I {return(forbidden())}"
        for (route, operation) in entry_number_routes(source, "x")
            error_text = try
                operation()
                ""
            catch failure
                sprint(showerror, failure)
            end
            @test occursin("parser-state helper", error_text) && occursin("entry_len", error_text)
        end
    end
    @testset "Preserve independently observed legacy results" begin
        source = entry_number_action(raw"""order="";result=match_len().add(0).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([match_len().set_key("k",1),entry_len().take(1),result,order]);""")
        check_entry_numbers(source, "name=Alpha", Any[Any[5, Any[], nothing, ""]])
    end
end
