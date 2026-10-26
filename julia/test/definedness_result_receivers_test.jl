# TYPE-REFERENCE-BOOK.1.2.23.3.11.4: definedness results retain scalar boundaries.
function check_definedness_result_consumers(source, expected)
    function same(actual)
        @test actual == expected
        if expected isa AbstractVector
            @test actual isa AbstractVector && all(actual[index] isa Bool
                for index in eachindex(expected) if expected[index] isa Bool)
        end
    end
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    actual = runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value
    actual == expected || println("native definedness: ", JSON3.write(actual))
    same(actual)
    same(execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "definedness-result-receivers.spec"))
    host = Module(gensym(:DefinednessResultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "definedness-result-receivers.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    same(Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end

function definedness_result_fixture(name, extension)
    root = dirname(dirname(@__DIR__))
    return read(joinpath(root, "tests", "fixtures", name * "." * extension), String)
end

@testset "Definedness result receiver boundaries" begin
    check_definedness_result_consumers(definedness_result_fixture("definedness_result_receiver_values", "spec"),
        JSON3.read(definedness_result_fixture("definedness_result_receiver_values", "json"), Any))
    check_definedness_result_consumers(raw"""Top:: I { return([is_defined([].first()),is_undefined([].first()),is_defined(""),is_defined(false),is_defined(0),is_defined([]),is_defined({}),cat(is_defined([].first()),"!"),coalesce_nonempty(is_defined([].first()),"late"),true.is_defined(),false.is_defined(),undef.is_undefined()]) }""",
        Any[false, true, true, true, true, true, true, "0!", false, true, true, true])
end
