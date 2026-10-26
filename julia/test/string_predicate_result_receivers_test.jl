# TYPE-REFERENCE-BOOK.1.2.23.3.10.4: string_predicate results retain scalar boundaries.
function check_string_predicate_result_consumers(source, expected)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    actual = runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value
    actual == expected || println("native string_predicate: ", JSON3.write(actual))
    @test actual == expected
    @test execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "string_predicate-result-receivers.spec") == expected
    host = Module(gensym(:StringPredicateResultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "string_predicate-result-receivers.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    @test Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x") == expected
end

function string_predicate_result_fixture(name, extension)
    root = dirname(dirname(@__DIR__))
    return read(joinpath(root, "tests", "fixtures", name * "." * extension), String)
end

@testset "String predicate result receiver boundaries" begin
    check_string_predicate_result_consumers(string_predicate_result_fixture("string_predicate_result_receiver_values", "spec"),
        JSON3.read(string_predicate_result_fixture("string_predicate_result_receiver_values", "json"), Any))
end
