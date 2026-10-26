# TYPE-REFERENCE-BOOK.1.2.23.3.14.5: actual null is a distinct Array key.
function check_null_array_key_consumers(source, expected; reference = false)
    function same(actual)
        actual == expected || println("native/plan/fresh Array keys: ", JSON3.write(actual))
        @test actual == expected
        if actual isa AbstractDict
            @test all(value isa Number && !(value isa Bool) for value in actual["membership"])
            @test all(value === nothing || (value isa Number && !(value isa Bool)) for value in actual["indexes"])
        end
        if reference
            @test all(actual[key] isa Number && !(actual[key] isa Bool) for key in
                ("numeric", "missing_index", "found_index", "unique_count", "unique_last", "needle_calls"))
            @test actual["unique"][1] === nothing
            @test length(actual["unique"]) == 3
            if length(actual["unique"]) == 3
                @test actual["unique"][2] isa AbstractString
                @test actual["unique"][3] isa Number && !(actual["unique"][3] isa Bool)
            end
        end
    end
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    same(runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value)
    same(execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "null-array-keys.spec"))
    host = Module(gensym(:NullArrayKeyGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "null-array-keys.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    same(Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end

@testset "Null Array key reference and defined conversions" begin
    root = dirname(dirname(@__DIR__))
    source = read(joinpath(root, "tests", "fixtures", "null_array_key_values.spec"), String)
    expected = JSON3.read(read(joinpath(root, "tests", "fixtures", "null_array_key_values.json"), String), Any)
    check_null_array_key_consumers(source, expected; reference = true)
    check_null_array_key_consumers(raw"""Top:: I { return({"membership":[contains([[]],""),contains([{}],""),contains([2],"2"),contains([false],0)],"indexes":[index_of([[]],""),index_of([{}],""),index_of([2],"2"),index_of([false],0)],"unique":uniq([[],"",{},2,"2",false,0]),"missing":[contains([undef]),index_of([undef])]}); }""",
        JSON3.read(raw"""{"membership":[1,1,1,1],"indexes":[0,0,0,0],"unique":[[],2,false],"missing":[0,null]}""", Any))
    check_null_array_key_consumers(raw"""Top:: I { return([contains([[]],undef),contains([undef],[]),index_of([[]],undef),index_of([undef],[]),uniq([[],undef,""])]); }""",
        JSON3.read(raw"""[0,0,null,null,[[],null]]""", Any))
end
