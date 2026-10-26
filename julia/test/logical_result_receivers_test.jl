# TYPE-REFERENCE-BOOK.1.2.23.3.17.4: actual Boolean result continuations.
function check_logical_result_consumers(source, expected)
    function same(actual)
        actual == expected || println("logical results: ", JSON3.write(actual))
        @test actual == expected
        if actual isa AbstractDict
            for (key, value) in expected
                if value isa Bool
                    @test actual[key] === value
                end
            end
            if haskey(actual, "raw")
                @test all(value isa Bool for value in actual["raw"])
            end
            if haskey(actual, "flag")
                @test actual["flag"] === false
                @test actual["meta"]["flag"] === true
                @test actual["fallback_calls"] isa Number && !(actual["fallback_calls"] isa Bool)
            end
        end
    end
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    same(runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value)
    same(execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), "x", "logical-results.spec"))
    host = Module(gensym(:LogicalResultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "logical-results.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    same(Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end

function capture_logical_result_error(operation)
    try
        operation()
    catch error
        return error
    end
    return nothing
end

@testset "Logical Boolean result boundaries and source errors" begin
    check_logical_result_consumers(raw"""Top:: I { raw=[and(true),and(false),or(false,true),or(false,0),not(false),not(true)];nested=[cat(and(true),"!"),cat(and(false),"!"),cat(or(false,true),"!"),cat(or(false,0),"!"),cat(not(false),"!"),cat(not(true),"!")];truthiness=[and("0"),or("false"),not([]),not({}),not([undef]),not({"a":undef})];numeric=[num_add(and(true),1),num_add(or(false),1)];source=true;order="";effected=cat(and({order=cat(order,"L");source},{order=cat(order,"R");source=false;false}),{order=cat(order,"C");source=undef;"!"});return({"raw":raw,"nested":nested,"truthiness":truthiness,"numeric":numeric,"effected":effected,"order":order,"source":source}); }""",
        JSON3.read(raw"""{"raw":[true,false,true,false,true,false],"nested":["1!","0!","1!","0!","1!","0!"],"truthiness":[true,true,true,true,false,false],"numeric":[null,null],"effected":"0!","order":"LRC","source":null}""", Any))
    root = dirname(dirname(@__DIR__))
    for name in ("logical_result_receiver_values", "logical_rejected_consumer_effects")
        source = read(joinpath(root, "tests", "fixtures", name*".spec"), String)
        expected = JSON3.read(read(joinpath(root, "tests", "fixtures", name*".json"), String), Any)
        check_logical_result_consumers(source, expected)
    end
    check_logical_result_consumers(raw"""Top:: I { return([[and(true)].first().sorted(),{or(false)}.sorted(),true.sorted()]) }""", Any[nothing,nothing,nothing])
    for (helper, arity, call) in (
        ("and",0,"and()"),("or",0,"or()"),("not",0,"not()"),
        ("not",2,raw"""not({fail("must-not-run")},{fail("must-not-run")})"""),
        ("not",2,raw"""not({print("must-not-run");true},{print("must-not-run");false})"""),
    )
        compiled = compile_spec(parse_spec_with_staged_user_function_definitions("Top:: I { return("*call*".cat(\"!\")) }"))
        error = capture_logical_result_error(() -> runtime_execute(LinkedSpecRuntimeEngine(compiled), "x"))
        @test error isa RuntimeInterpreterException
        if error isa RuntimeInterpreterException
            @test error.diagnostic !== nothing
            diagnostic = to_json(error.diagnostic)
            @test diagnostic["code"] == "helper_arity_mismatch"
            @test diagnostic["helper_name"] == helper
            @test diagnostic["actual_arity"] === arity
            @test diagnostic["rule_label"] == "Top"
        end
        host = Module(gensym(:LogicalErrorGenerated))
        Base.include_string(host, emit_julia_source_v2(compiled, "logical-results.spec"))
        parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
        for operation in (
            () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), "x", "logical-results.spec"),
            () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"),
        )
            error = capture_logical_result_error(operation)
            @test error isa GeneratedSourceException
            if error isa GeneratedSourceException
                @test occursin("helper_arity_mismatch", error.detail)
                @test occursin("helper_name="*helper, error.detail)
                @test occursin("actual_arity="*string(arity), error.detail)
            end
        end
    end
end
