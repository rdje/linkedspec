# TYPE-REFERENCE-BOOK.1.2.23.3.19.4: scalar String-helper result continuations.
function check_scalar_string_consumers(source, expected; verify=identity)
    function same(actual)
        actual == expected || println("scalar String results: ", JSON3.write(actual))
        @test actual == expected
        verify(actual)
    end
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    same(runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value)
    same(execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), "x", "scalar-string-results.spec"))
    host = Module(gensym(:ScalarStringGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "scalar-string-results.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    same(Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end

@testset "Healthy existing scalar String producers" begin
    check_scalar_string_consumers(raw"""Top:: I { source="a-b";order="";value=replace_substr({order=cat(order,"S");source},{order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"});return([[trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b")],[lowercase("ΟΣ"),uppercase("Straße ﬃ"),substr("a🙂b",1,1)],cat(undef,"x"),value,order,source]); }""", JSON3.read(raw"""[["a","ab","AB","a_b","a","a","bc","ab"],["ος","STRASSE FFI","🙂"],null,"a_b","SON","changed"]""", Any))
end

@testset "Scalar String kinds boundaries and reference slices" begin
    @testset "Identity kinds and explicit null operands" begin
        check_scalar_string_consumers(raw"""Top:: I { return([replace_substr(0,"","X"),rm_prefix(0,"x"),rm_suffix(0,"x"),rm_prefix(false,"x"),rm_suffix(false,"x"),rm_prefix("0","x"),replace_substr("abc",undef,"x"),replace_substr("abc","a",undef),rm_prefix("abc",undef),rm_suffix("abc",undef)]); }""", Any[0,0,0,false,false,"0",nothing,nothing,nothing,nothing]; verify=actual->begin
            @test all(value isa Number && !(value isa Bool) for value in actual[1:3])
            @test actual[4] === false
            @test actual[5] === false
            @test actual[6] isa AbstractString
        end)
    end
    @testset "Receiver source and shape effects" begin
        check_scalar_string_consumers(raw"""Top:: I { order="";value={order=cat(order,"S");" a "}.trim().cat({order=cat(order,"C");"!"}).take({order=cat(order,"A");1});bad_order="";bad={bad_order=cat(bad_order,"S");"a"}.replace_substr({bad_order=cat(bad_order,"A");"x"}).cat({bad_order=cat(bad_order,"C");"!"});return([value,order,bad,bad_order]); }""", Any[nothing,"SC",nothing,""])
    end
    @testset "Producer identity selectors" begin
        check_scalar_string_consumers(raw"""Top:: I { raw=[trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b")];identity=[replace_substr(0,"","X"),rm_prefix(0,"x"),rm_suffix(false,"x")];values=["zero","one"];values[rm_prefix(0,"x")]="prefix";values[rm_suffix(1,"x")]="suffix";unicode=[lowercase("ΟΣ"),uppercase("Straße ﬃ"),substr("a🙂b",1,1)];source="a-b";order="";replaced=replace_substr({order=cat(order,"S");source},{order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"});return([raw,identity,values,unicode,replaced,order,source,cat(undef,"x")]); }""", JSON3.read(raw"""[["a","ab","AB","a_b","a","a","bc","ab"],[0,0,false],["prefix","suffix"],["ος","STRASSE FFI","🙂"],"a_b","SON","changed",null]""", Any); verify=actual->begin
            @test actual[2][1] isa Number && !(actual[2][1] isa Bool)
            @test actual[2][3] === false
        end)
    end
    @testset "Shared scalar String result values" begin
        root = dirname(dirname(@__DIR__))
        source = read(joinpath(root,"tests","fixtures","scalar_string_result_receiver_values.spec"),String)
        expected = JSON3.read(read(joinpath(root,"tests","fixtures","scalar_string_result_receiver_values.json"),String),Any)
        check_scalar_string_consumers(source,expected;verify=actual->begin
            @test all(value isa Number && !(value isa Bool) for value in actual["identity"][1:3])
            @test actual["identity"][4] === false
            @test actual["identity"][5] === false
            @test actual["identity"][6] isa AbstractString
            @test actual["calls"] isa Number && !(actual["calls"] isa Bool)
        end)
    end
    @testset "Reference substring arguments" begin
        check_scalar_string_consumers(raw"""Top:: I { order="";source=substr({order=cat(order,"S");undef},{order=cat(order,"I");0},{order=cat(order,"L");1});start=substr("abc",undef);return([source,start,undef.substr(0),"abc".substr(undef),substr("abc",0,undef),order,substr("abc",1.5),substr("abc",-1,1),substr("abc",0,1.5),substr("abc",0,-1),substr("abc",true)]); }""", Any[nothing,nothing,nothing,nothing,nothing,"SIL","abc","a","","","bc"])
    end
    @testset "Dedicated named-target regex mutation" begin
        check_scalar_string_consumers(raw"""Top:: I { text="aba";substr(text,/a/,"x","g");other="aba";regex_subst(other,/a/,"y","");return([text,other]); }""", Any["xbx","yba"])
    end
end
