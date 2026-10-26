# TYPE-REFERENCE-BOOK.1.2.23.3.8.4: has_key results retain scalar boundaries.
function check_has_key_result_consumers(source, expected)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    actual = runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value
    actual == expected || println("native has_key: ", JSON3.write(actual))
    @test actual == expected
    @test execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "has-key-result-receivers.spec") == expected
    host = Module(gensym(:HasKeyResultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "has-key-result-receivers.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    @test Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x") == expected
end

function has_key_result_fixture(name, extension)
    root = dirname(dirname(@__DIR__))
    return read(joinpath(root, "tests", "fixtures", name * "." * extension), String)
end

@testset "Has_key result receiver boundaries" begin
    check_has_key_result_consumers(has_key_result_fixture("has_key_result_receiver_values", "spec"),
        JSON3.read(has_key_result_fixture("has_key_result_receiver_values", "json"), Any))
end
