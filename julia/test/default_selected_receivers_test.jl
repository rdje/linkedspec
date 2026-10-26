# TYPE-REFERENCE-BOOK.1.2.23.3.6.4: default results retain the selected kind.
function check_default_selection_consumers(source, expected)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value == expected
    @test execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "default-selected-receivers.spec") == expected
    host = Module(gensym(:DefaultSelectionGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "default-selected-receivers.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    @test Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x") == expected
end

function default_selection_fixture(name)
    root = dirname(dirname(@__DIR__))
    return read(joinpath(root, "tests", "fixtures", name * ".spec"), String)
end

@testset "Selected default receiver boundaries" begin
    check_default_selection_consumers(default_selection_fixture("default_selected_receiver_values"),
        JSON3.read(raw"""["A-B","A-B","A-B","X:Y","KEPT",null,null,null,"A-B",null,1,1,3,"0!","A-B","SDJ",["a","b","c"],"KEPT","",["a","b"],{"a":"x","b":"y"},"X:Y"]""", Any))
    check_default_selection_consumers(
        raw"""Top:: I { return(["kept".coalesce_nonempty(["a"]).sorted(), "".coalesce_nonempty("kept").sorted(), "kept".coalesce_nonempty({"k":1}).sorted_values()]); }""",
        Any[nothing, nothing, nothing])
    check_default_selection_consumers(default_selection_fixture("coalesce_receiver_values"),
        Any["first", "CHOSEN", "SELECTED", "empty", 0, false, nothing, "A", "ABCDEF"])
end
