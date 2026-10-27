# TYPE-REFERENCE-BOOK.1.2.23.3.22.4 — tagged-record String-to-Array receiver.
function check_tagged_records(source, expected; verify=identity)
    function same(actual)
        @test actual == expected
        verify(actual)
    end
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    same(runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value)
    same(execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), "x", "tagged-record-results.spec"))
    host = Module(gensym(:TaggedRecordGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "tagged-record-results.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    same(Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end

@testset "Tagged-record eager producer" begin
    check_tagged_records(raw"""Top:: I { counter=0;records=split_tagged_records("a,b,",",","row",set(counter,num_add(counter,1)),false,null,["x"],{"key":"v"});empty=split_tagged_records("",",","row",set(counter,num_add(counter,1)));return([records,empty,counter,split("a,b,",","),split("",",")]); }""",JSON3.read(raw"""[[["row","a",1,false,null,["x"],{"key":"v"}],["row","b",1,false,null,["x"],{"key":"v"}],["row","",1,false,null,["x"],{"key":"v"}]],[["row","",2]],2,["a","b",""],[""]]""",Any);verify=actual->begin
        @test actual[1][1][3] isa Number && !(actual[1][1][3] isa Bool)
        @test actual[1][1][4] === false
        @test actual[1][1][5] === nothing
        @test actual[3] isa Number && !(actual[3] isa Bool)
    end)
end
@testset "Tagged-record String receiver and boundaries" begin
    @testset "Shared valid chains" begin
        root=dirname(dirname(@__DIR__))
        source=read(joinpath(root,"tests","fixtures","tagged_record_receiver_values.spec"),String)
        expected=JSON3.read(read(joinpath(root,"tests","fixtures","tagged_record_receiver_values.json"),String),Any)
        check_tagged_records(source,expected;verify=actual->begin
            @test actual[3] isa Number && !(actual[3] isa Bool)
            @test actual[5] isa Number && !(actual[5] isa Bool)
            @test actual[6] === false
            @test actual[11][5] isa Number && !(actual[11][5] isa Bool)
        end)
    end
    @testset "Earlier arguments and row copies" begin
        check_tagged_records(raw"""Top:: I { carried=["x"];number=7;records=split_tagged_records("a,b",",","row",carried,number,{carried+="later";number=9;number});records[0][2][0]="changed";return([records,carried,number]); }""",JSON3.read(raw"""[[["row","a",["changed"],7,9],["row","b",["x"],7,9]],["x","later"],9]""",Any);verify=actual->begin
            @test actual[1][1][4] isa Number && !(actual[1][1][4] isa Bool)
            @test actual[3] isa Number && !(actual[3] isa Bool)
        end)
    end
    @testset "Minimum shape rejects before effects" begin
        check_tagged_records(raw"""Top:: I { order="";bad0={order=cat(order,"S");"a,b"}.split_tagged_records().count();bad1={order=cat(order,"S");"a,b"}.split_tagged_records({order=cat(order,"D");","}).take({order=cat(order,"C");1});return([bad0,bad1,order]); }""",Any[nothing,nothing,""];verify=actual->begin
            @test actual[1] === nothing
            @test actual[2] === nothing
        end)
    end
    @testset "Short free call preservation" begin
        check_tagged_records(raw"""Top:: I { order="";short=split_tagged_records({order=cat(order,"S");"a,b"},{order=cat(order,"D");","});return([split_tagged_records(),short,order]); }""",Any[Any[],Any[],"SD"])
    end
end
