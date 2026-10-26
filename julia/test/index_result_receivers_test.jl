# TYPE-REFERENCE-BOOK.1.2.23.3.7.4: index results retain integer/null boundaries.
function check_index_result_consumers(source, expected)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value == expected
    @test execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "index-result-receivers.spec") == expected
    host = Module(gensym(:IndexResultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "index-result-receivers.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    @test Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x") == expected
end

function index_result_fixture(name)
    root = dirname(dirname(@__DIR__))
    return read(joinpath(root, "tests", "fixtures", name * ".spec"), String)
end

@testset "Index result receiver boundaries" begin
    check_index_result_consumers(index_result_fixture("index_result_receiver_values"),
        JSON3.read(raw"""[2,2,1,null,null,null,2,2,2,2,2,2,"1!","X",8,null,null,null,2,"SNA",["a","b","c","d"],null,"N",["a","b"],null,"SN",["a","b"],["zero","old"],null,null,0,["a","b"],{"a":"a","b":"b"}]""", Any))
    check_index_result_consumers(
        raw"""Top:: I { return([].first().index_of("a").sorted()); }""", nothing)
end
