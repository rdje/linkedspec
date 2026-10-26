# TYPE-REFERENCE-BOOK.1.2.23.3.13.4: contains results retain scalar boundaries.
function check_contains_result_consumers(source, expected)
    function same(actual)
        @test actual == expected
        @test all(value isa Number && !(value isa Bool) for value in actual["raw"])
    end
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    actual = runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value
    actual == expected || println("native contains: ", JSON3.write(actual))
    same(actual)
    same(execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "contains-result-receivers.spec"))
    host = Module(gensym(:ContainsResultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "contains-result-receivers.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    same(Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end

function contains_result_fixture(name, extension)
    root = dirname(dirname(@__DIR__))
    return read(joinpath(root, "tests", "fixtures", name * "." * extension), String)
end

@testset "Array contains result receiver boundaries" begin
    check_contains_result_consumers(raw"""Top:: I { items=["a","b"]; raw=[contains(["a","b"],"a"),contains(["a","b"],"z"),contains([],"a"),contains([undef],undef),contains([undef],""),contains([""],undef),contains([""],""),contains([0],"0"),contains([false],0)]; order=""; value=contains(items,{order=cat(order,"O");items=["z"];"a"});missing=[].first(); missing_order=""; missing_value=contains(missing,{missing_order=cat(missing_order,"O");missing=["a"];"a"});return({"raw":raw,"snapshot_absent":[missing_value,missing_order,missing],"snapshot":[value,order,items],"text":[cat(contains(["a"],"z"),"!"),cat(coalesce_nonempty(contains(["a"],"z"),"late"),"!")]}) }""",
        JSON3.read(raw"""{"raw":[1,0,0,1,0,0,1,1,1],"snapshot":[1,"O",["z"]],"snapshot_absent":[0,"O",["a"]],"text":["0!","0!"]}""", Any))
    check_contains_result_consumers(contains_result_fixture("contains_result_receiver_values", "spec"),
        JSON3.read(contains_result_fixture("contains_result_receiver_values", "perl.json"), Any))
end
