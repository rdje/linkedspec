# TYPE-REFERENCE-BOOK.1.2.23.3.5.4: numeric producer results retain actual values.
function check_joined_string_consumers(source, expected)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value == expected
    @test execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "joined-string-receivers.spec") == expected
    host = Module(gensym(:JoinedStringGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "joined-string-receivers.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    @test Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x") == expected
end

@testset "Joined String receiver boundaries" begin
    source=raw"""fn joined(values) { return(values.join_values(":").uppercase()) }
Top:: /x/ E {
 named_parts=["a","b"]; mutated=named_parts.push_back("c").join_values(",").uppercase(); incompatible_mutated=named_parts.push_back("d").join_values(",").sorted();
 parts=[" a ","b "]; saved=copy(parts); meta={"b":"y","a":"x"};
 direct=parts.join_values("-").trim().uppercase();
 selected=[["a","b"]].first().join_values("-").uppercase();
 pipeline=["b","a"].sorted().join_values(":").uppercase();
 from_hash=meta.sorted_values().join_values(":").uppercase();
 string="a-b".split("-").join_values(":").uppercase();
 numeric=["a","b"].join_values(":").length().add(1);
 repeated=["a","b"].join_values(":").split(":").last().uppercase();
 from_function=joined(["a","b"]); empty=[].join_values(",").cat("!");
 unicode=["ß","a"].join_values(" ").uppercase();
 items=["a","b"]; order="";
 effected={order=cat(order,"S");items}.join_values({order=cat(order,"D");items+="c";","}).cat({order=cat(order,"A");items+="d";"!"});
 bare=["x","y"]; named=bare.join_values({order=cat(order,"N");bare+="z";"-"}).uppercase();
 invalid_effects=0;
 missing={invalid_effects=num_add(invalid_effects,1);["a"]}.join_values().uppercase();
 extra={invalid_effects=num_add(invalid_effects,1);["a"]}.join_values({invalid_effects=num_add(invalid_effects,1);","},{invalid_effects=num_add(invalid_effects,1);"!"}).uppercase();
 incompatible=["a"].join_values(",").sorted();
 return([mutated,incompatible_mutated,named_parts,direct,selected,pipeline,from_hash,string,numeric,repeated,from_function,empty,unicode,effected,named,order,items,bare,parts,saved,meta,missing,extra,invalid_effects,incompatible]);
}"""
    expected=Any["A,B,C",nothing,Any["a","b","c","d"],"A -B","A-B","A:B","X:Y","A:B",4,"B","A:B","!","SS A","a,b!","X-Y","SDAN",Any["a","b","c","d"],Any["x","y","z"],Any[" a ","b "],Any[" a ","b "],Dict("a"=>"x","b"=>"y"),nothing,nothing,0,nothing]
    check_joined_string_consumers(source, expected)
end
