# TYPE-REFERENCE-BOOK.1.2.23.3.21.4 — actual reduction result continuations.
function check_reduction_consumers(source, expected; verify=identity)
    function same(actual)
        @test actual == expected
        verify(actual)
    end
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    same(runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value)
    same(execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), "x", "reduction-results.spec"))
    host = Module(gensym(:ReductionResultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "reduction-results.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    same(Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end

@testset "Admitted reduction accumulator producers" begin
    check_reduction_consumers(raw"""Top:: I { return([[1,[2,3]].reduce_leaves(0) { return(acc.add(value)) },["a",["b"]].reduce_leaves("") { return(cat(acc,value)) },[1,[2,3]].reduce_leaves([]) { return(concat_arrays(acc,[value])) },[1].reduce_leaves({}) { return({"key":"B"}) },[].reduce_leaves(false) { return(true) },[1].reduce_leaves(0) { return(undef) },[].reduce_leaves(["empty"]) { return(value) },{"b":2,"a":1}.reduce_leaves(0) { return(acc.add(value)) }]); }""", JSON3.read(raw"""[6,"ab",[1,2,3],{"key":"B"},false,null,["empty"],3]""",Any);verify=actual->begin
        @test actual[1] isa Number && !(actual[1] isa Bool)
        @test actual[5] === false
        @test actual[6] === nothing
    end)
end

@testset "Reduction results and traversal boundaries" begin
    @testset "Admitted walk map and plain reduction" begin
        check_reduction_consumers(raw"""Top:: I { original=[1,[2]];seen=[];walked=original.walk_leaves() {seen+=join_values("/",path);return(99)};mapped=original.map_leaves() {return(value.add(1))};meta={"b":{"y":2},"a":1,"arr":[9]};paths=[];hash=meta.walk_leaves() {paths+=join_values("/",path);return(0)};return([original,walked,mapped,seen,hash,paths,[1,[2]].reduce_leaves(0) {return(acc.add(value))}]); }""", JSON3.read(raw"""[[1,[2]],[1,[2]],[2,[3]],["0","1/0"],{"b":{"y":2},"a":1,"arr":[9]},["a","arr","b/y"],3]""",Any))
    end
    @testset "Shared exact data results and scopes" begin
        root = dirname(dirname(@__DIR__))
        source = read(joinpath(root,"tests","fixtures","reduction_result_receiver_values.spec"),String)
        expected = JSON3.read(read(joinpath(root,"tests","fixtures","reduction_result_receiver_values.json"),String),Any)
        check_reduction_consumers(source,expected;verify=actual->begin
            @test actual["effects"][3] isa Number && !(actual["effects"][3] isa Bool)
        end)
    end
    @testset "Source capture and initial callback consumer order" begin
        check_reduction_consumers(raw"""Top:: I { items=[1,2];order="";calls=0;result={order=cat(order,"S");calls=num_add(calls,1);items}.reduce_leaves({order=cat(order,"I");items=[9];0}) {order=cat(order,"L");return(acc.add(value))}.cat({order=cat(order,"C");items=undef;"!"});return([result,order,calls,items]); }""",Any["3!","SILLC",1,nothing];verify=actual->begin
            @test actual[3] isa Number && !(actual[3] isa Bool)
        end)
    end
    @testset "Invalid roots skip initial and callbacks" begin
        check_reduction_consumers(raw"""Top:: I { order="";result={order=cat(order,"S");"x"}.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(value)};other=undef.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(value)};return([result,other,order]); }""",Any[nothing,nothing,"S"];verify=actual->begin
            @test actual[1] === nothing
            @test actual[2] === nothing
        end)
    end
    @testset "Opposite container consumers skip operands" begin
        check_reduction_consumers(raw"""Top:: I { order="";a={order=cat(order,"S");[1]}.reduce_leaves({order=cat(order,"I");[]}) {order=cat(order,"L");return(acc)}.set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});first=[a,order];order="";b={order=cat(order,"S");[1]}.reduce_leaves({order=cat(order,"I");{}}) {order=cat(order,"L");return(acc)}.take({order=cat(order,"A");1});return([first,[b,order]]); }""",Any[Any[nothing,"SIL"],Any[nothing,"SIL"]])
    end
    @testset "Malformed arity keeps compile-time signature errors" begin
        for source in (raw"""Top:: I { return([1].reduce_leaves() {return(value)}.cat("!")); }""",raw"""Top:: I { return([1].reduce_leaves(0,1) {return(value)}.cat("!")); }""")
            failure = try
                compile_spec(parse_spec_with_staged_user_function_definitions(source))
                nothing
            catch error
                error
            end
            @test failure isa CompiledSpecException
            @test occursin("callable_contract_arity_mismatch",sprint(showerror,failure))
        end
    end
end
