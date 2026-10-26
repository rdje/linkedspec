# TYPE-REFERENCE-BOOK.1.2.23.3.18.4: defined-only default receivers.
function check_defined_default_consumers(source, expected; verify=identity)
    function same(actual)
        actual == expected || println("defined defaults: ", JSON3.write(actual))
        @test actual == expected
        verify(actual)
    end
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    same(runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value)
    same(execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), "x", "defined-defaults.spec"))
    host = Module(gensym(:DefinedDefaultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "defined-defaults.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    same(Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end

@testset "Existing defined-only default producers" begin
    check_defined_default_consumers(raw"""Top:: I { raw=[coalesce(undef,"fallback"),coalesce("","late"),coalesce(0,7),coalesce(false,true),coalesce(undef,undef),coalesce(undef,[2,3]),coalesce(undef,{"a":"a","b":"b"})];nested=[uppercase(trim(coalesce(undef," chosen "))),cat(coalesce(false,true),"!")];hits=0;lazy=coalesce("",{hits=num_add(hits,1);"late"},{target=1;target[0]=2;"bad"});items=["a","b"];chosen=coalesce(undef,items);items[0]="z";values=["zero","one"];values[coalesce(undef,1)]="updated";return([raw,nested,lazy,hits,chosen,items,values]); }""",
        JSON3.read(raw"""[["fallback","",0,false,null,[2,3],{"a":"a","b":"b"}],["CHOSEN","0!"],"",0,["a","b"],["z","b"],["zero","updated"]]""", Any);
        verify = actual -> begin
            @test actual[1][4] === false
            @test actual[1][3] isa Number && !(actual[1][3] isa Bool)
            @test actual[4] isa Number && !(actual[4] isa Bool)
        end)
end

@testset "Defined-only receiver kinds snapshots and boundaries" begin
    root = dirname(dirname(@__DIR__))
    source = read(joinpath(root, "tests", "fixtures", "defined_default_receiver_values.spec"), String)
    expected = JSON3.read(read(joinpath(root, "tests", "fixtures", "defined_default_receiver_values.json"), String), Any)
    check_defined_default_consumers(source, expected; verify = actual -> begin
        @test actual["raw"][4] === false
        @test actual["lazy"][2] === false
        @test actual["raw"][3] isa Number && !(actual["raw"][3] isa Bool)
        @test actual["text"][3] isa Number && !(actual["text"][3] isa Bool)
        @test actual["calls"] isa Number && !(actual["calls"] isa Bool)
        @test actual["hits"] isa Number && !(actual["hits"] isa Bool)
    end)
    check_defined_default_consumers(raw"""Top:: I { order="";named=undef;flag=false;return([named.coalesce("kept").sorted(),[].first().coalesce("kept").sorted_values(),flag.coalesce(true).take({order=cat(order,"A");1}),{order=cat(order,"S");true}.coalesce().cat({order=cat(order,"C");"!"}),order]); }""", Any[nothing,nothing,nothing,nothing,""])
end
