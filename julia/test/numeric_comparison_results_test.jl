# TYPE-REFERENCE-BOOK.1.2.23.3.15.4: numeric flags remain Numbers, not Bool lookalikes.
function check_numeric_comparison_result_consumers(source, expected)
    function same(actual)
        actual == expected || println("numeric comparison results: ", JSON3.write(actual))
        @test actual == expected
        if actual isa AbstractDict
            @test all(value isa Number && !(value isa Bool) for value in actual["raw"])
            if haskey(actual, "aliases")
                @test all(value isa Number && !(value isa Bool) for value in actual["aliases"])
                @test all(value isa Number && !(value isa Bool) for value in actual["boundaries"][1:2])
            end
            if haskey(actual, "numeric")
                @test all(value isa Number && !(value isa Bool) for value in actual["numeric"][1:2])
                @test all(actual[key] isa Number && !(actual[key] isa Bool) for key in
                    ("source_calls", "operand_calls", "invalid_effects", "null_effected"))
            end
        end
    end
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    same(runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value)
    same(execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "numeric-comparison-results.spec"))
    host = Module(gensym(:NumericComparisonResultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "numeric-comparison-results.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    same(Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end

@testset "Numeric comparison result kinds and receiver boundaries" begin
    check_numeric_comparison_result_consumers(raw"""Top:: I { raw=[num_eq(2,2),num_ne(2,3),num_gt(3,2),num_ge(2,2),num_lt(2,3),num_le(2,2),num_eq(2,3),num_ne(2,2),num_gt(2,3),num_ge(2,3),num_lt(3,2),num_le(3,2)];boundaries=[num_eq("02","2"),num_eq("-.5",-0.5),num_eq(undef,0),num_eq(false,0),num_eq(true,1),num_eq("",0),num_eq("x",0),num_eq([],0),num_eq({},0),num_eq(2),num_eq(2,2,2)];aliases=[eq(2,2),ne(2,2),gt(2,1),ge(2,2),lt(2,3),le(2,2),==(2,2),!=(2,2),>(2,1),>=(2,2),<(2,3),<=(2,2)];nested=[cat(num_eq(2,2),"!"),cat(coalesce_nonempty(num_eq(2,3),"late"),"!"),num_add(num_eq(2,3),2),uppercase(last(split(cat(num_eq(2,2),",x"),",")))];source=2;order="";effected=cat(num_eq({order=cat(order,"S");source},{order=cat(order,"O");source=3;2}),{order=cat(order,"C");source=undef;"!"});return({"raw":raw,"boundaries":boundaries,"aliases":aliases,"nested":nested,"effected":effected,"order":order,"source":source}); }""",
        JSON3.read(raw"""{"raw":[1,1,1,1,1,1,0,0,0,0,0,0],"boundaries":[1,1,null,null,null,null,null,null,null,null,null],"aliases":[1,0,1,1,1,1,1,0,1,1,1,1],"nested":["1!","0!",2,"X"],"effected":"1!","order":"SOC","source":null}""", Any))
    root = dirname(dirname(@__DIR__))
    source = read(joinpath(root, "tests", "fixtures", "numeric_comparison_result_receiver_values.spec"), String)
    expected = JSON3.read(read(joinpath(root, "tests", "fixtures", "numeric_comparison_result_receiver_values.json"), String), Any)
    check_numeric_comparison_result_consumers(source, expected)
    check_numeric_comparison_result_consumers(raw"""Top:: I { score=2;values=["zero","one"];values[score.eq(2)]="updated";return(values) }""", Any["zero","updated"])
end
