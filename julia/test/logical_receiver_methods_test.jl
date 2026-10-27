# TYPE-REFERENCE-BOOK.1.2.23.3.23.4 — ordinary logical receiver methods.
function check_logical_methods(source, expected; verify=identity)
    function same(actual)
        @test actual == expected
        verify(actual)
    end
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    same(runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value)
    same(execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), "x", "logical-receiver-methods.spec"))
    host = Module(gensym(:LogicalMethodGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "logical-receiver-methods.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    same(Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end

function capture_logical_method_error(operation)
    try
        operation()
    catch error
        return error
    end
    return nothing
end

@testset "Existing logical producers and copy policy" begin
    check_logical_methods(raw"""Top:: I { return([and(true,false),or(false,true),not(false),not("0"),not(0),not([]),not([null]),not({}),not({"key":null})]); }""",Any[false,true,true,false,true,true,false,true,false];verify=actual->begin
        @test all(value isa Bool for value in actual)
    end)
    check_logical_methods(raw"""Top:: I { return([and(true).copy(),true.copy(),copy(false)]); }""",Any[true,true,false];verify=actual->begin
        @test all(value isa Bool for value in actual)
    end)
end

@testset "Ordinary logical receiver methods" begin
    @testset "Shared valid sources and actual kinds" begin
        root=dirname(dirname(@__DIR__))
        source=read(joinpath(root,"tests","fixtures","logical_receiver_method_values.spec"),String)
        expected=JSON3.read(read(joinpath(root,"tests","fixtures","logical_receiver_method_values.json"),String),Any)
        check_logical_methods(source,expected;verify=actual->begin
            @test all(value isa Bool for value in actual[1])
            @test all(value isa Bool for value in actual[2])
            @test actual[3] === false
            @test actual[4] === true
            @test actual[5] === true
            @test actual[9][3] isa Number && !(actual[9][3] isa Bool)
            @test actual[9][4] === true
            @test actual[11][1] === false
            @test actual[12][1] === true
            @test actual[12][3] === false
            @test actual[12][4]["ready"] === false
        end)
    end
    @testset "Valid prefixes skip incompatible consumer operands" begin
        check_logical_methods(raw"""Top:: I { order="";a={order=cat(order,"S");false}.and({order=cat(order,"R");true}).take({order=cat(order,"A");1});first=[a,order];order="";b={order=cat(order,"S");false}.or({order=cat(order,"R");true}).cat({order=cat(order,"C");"!"}).set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});return([first,[b,order]]); }""",Any[Any[nothing,"SR"],Any[nothing,"SRC"]])
    end
    @testset "With scope and copy recovery preserve existing behavior" begin
        check_logical_methods(raw"""Top:: I { value="outer";order="";a="x".with() {order=cat(order,"W");return(false)}.not();return([a,order,value]); }""",Any[true,"W","outer"];verify=actual->begin
            @test actual[1] === true
        end)
        check_logical_methods(raw"""Top:: I { value="outer";order="";a="x".with() {order=cat(order,"W");return(false)}.not().take({order=cat(order,"A");1});return([a,order,value]); }""",Any[nothing,"W","outer"];verify=actual->begin
            @test actual[1] === nothing
        end)
        check_logical_methods(raw"""Top:: I { scalar="x".with() {return(false)}.not().copy();hash="x".with() {return(false)}.not().add(1).coalesce({"key":7}).copy().sorted_values().first().add(1);array="x".with() {return(false)}.not().add(1).coalesce([7]).copy().first().add(1);return([scalar,hash,array]); }""",Any[true,8,8];verify=actual->begin
            @test actual[1] === true
            @test actual[2] isa Number && !(actual[2] isa Bool)
            @test actual[3] isa Number && !(actual[3] isa Bool)
        end)
    end
    @testset "Invalid free sources keep typed diagnostics" begin
        for (helper,arity,expression) in (("and",0,"and().not()"),("not",2,raw"""not({fail("must-not-run")},{fail("must-not-run")}).or(true)"""))
            source="Top:: I { return("*expression*") }"
            compiled=compile_spec(parse_spec_with_staged_user_function_definitions(source))
            error=capture_logical_method_error(() -> runtime_execute(LinkedSpecRuntimeEngine(compiled),"x"))
            @test error isa RuntimeInterpreterException
            if error isa RuntimeInterpreterException
                @test error.diagnostic !== nothing
                diagnostic=to_json(error.diagnostic)
                @test diagnostic["code"] == "helper_arity_mismatch"
                @test diagnostic["helper_name"] == helper
                @test diagnostic["actual_arity"] === arity
                @test diagnostic["rule_label"] == "Top"
            end
            host=Module(gensym(:LogicalMethodErrorGenerated))
            Base.include_string(host,emit_julia_source_v2(compiled,"logical-method-errors.spec"))
            parser=Base.invokelatest(getfield,host,:LinkedSpecGeneratedParser)
            for operation in (() -> execute_generated_parser_v2(compiled,build_generated_rule_plan(compiled),"x","logical-method-errors.spec"),() -> Base.invokelatest(Base.invokelatest(getfield,parser,:execute),"x"))
                error=capture_logical_method_error(operation)
                @test error isa GeneratedSourceException
                if error isa GeneratedSourceException
                    @test occursin("helper_arity_mismatch",error.detail)
                    @test occursin("helper_name="*helper,error.detail)
                    @test occursin("actual_arity="*string(arity),error.detail)
                end
            end
        end
    end
    @testset "New method shapes reject before effects" begin
        check_logical_methods(raw"""Top:: I { order="";a={order=cat(order,"S");true}.and().cat({order=cat(order,"C");"!"});b={order=cat(order,"S");false}.or().cat({order=cat(order,"C");"!"});c={order=cat(order,"S");false}.not({order=cat(order,"A");true}).cat({order=cat(order,"C");"!"});return([a,b,c,order]); }""",Any[nothing,nothing,nothing,""])
    end
    @testset "Invalid method skips unknown operand" begin
        check_logical_methods(raw"""Top:: I { order="";a={order=cat(order,"S");false}.not(fail("must-not-run"));return([a,order]); }""",Any[nothing,""])
    end
end
