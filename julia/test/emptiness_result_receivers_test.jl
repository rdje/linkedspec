# TYPE-REFERENCE-BOOK.1.2.23.3.9.4: emptiness results retain scalar boundaries.
function check_emptiness_result_consumers(source, expected)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    actual = runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value
    actual == expected || println("native emptiness: ", JSON3.write(actual))
    @test actual == expected
    @test execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "emptiness-result-receivers.spec") == expected
    host = Module(gensym(:EmptinessResultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "emptiness-result-receivers.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    @test Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x") == expected
end

function emptiness_result_fixture(name, extension)
    root = dirname(dirname(@__DIR__))
    return read(joinpath(root, "tests", "fixtures", name * "." * extension), String)
end

@testset "Emptiness result receiver boundaries" begin
    check_emptiness_result_consumers(emptiness_result_fixture("emptiness_result_receiver_values", "spec"),
        JSON3.read(emptiness_result_fixture("emptiness_result_receiver_values", "json"), Any))
end
