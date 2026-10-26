# TYPE-REFERENCE-BOOK.1.2.23.3.12.4: string_comparison results retain scalar boundaries.
function check_string_comparison_result_consumers(source, expected)
    function same(actual)
        @test actual == expected
        @test all(value isa Bool for value in actual["raw"])
    end
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    actual = runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value
    actual == expected || println("native string_comparison: ", JSON3.write(actual))
    same(actual)
    same(execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "string_comparison-result-receivers.spec"))
    host = Module(gensym(:StringComparisonResultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "string_comparison-result-receivers.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    same(Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end

function string_comparison_result_fixture(name, extension)
    root = dirname(dirname(@__DIR__))
    return read(joinpath(root, "tests", "fixtures", name * "." * extension), String)
end

@testset "String comparison result receiver boundaries" begin
    check_string_comparison_result_consumers(raw"""Top:: I { word="abc"; zero_text="0"; raw=[str_eq(word,"abc"),str_ne(word,"z"),str_gt(word,"aaa"),str_ge(word,"abc"),str_lt(word,"zzz"),str_le(word,"abc"),str_eq(word,"z"),str_ne(word,"abc"),str_gt(word,"zzz"),str_ge(word,"zzz"),str_lt(word,"aaa"),str_le(word,"aaa")]; order=""; null_result=str_eq({order=cat(order,"S");undef},{order=cat(order,"O");"a"});return({"raw":raw,"boundaries":[str_eq(undef,""),str_eq("",undef),str_eq("",""),str_eq("0",zero_text),str_eq(zero_text,"0")],"text":[cat(str_eq("a","b"),"!"),cat(coalesce_nonempty(str_eq("a","b"),"late"),"!")],"null_result":null_result,"order":order}) }""",
        JSON3.read(raw"""{"raw":[true,true,true,true,true,true,false,false,false,false,false,false],"boundaries":[null,null,true,true,true],"text":["0!","0!"],"null_result":null,"order":"SO"}""", Any))
    check_string_comparison_result_consumers(string_comparison_result_fixture("string_comparison_result_receiver_values", "spec"),
        JSON3.read(string_comparison_result_fixture("string_comparison_result_receiver_values", "null.json"), Any))
end
