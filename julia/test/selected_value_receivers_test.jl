@testset "Selected value receiver continuations" begin
    source = raw"""fn clone_first(values) { return(values.first().copy()) }
Top::
 /x/
 E {
  nested=[[3,1],[2]]; saved=copy(nested); rows=[{"b":2,"a":1}];
  copied_array=clone_first(nested); copied_hash=clone_first(rows);
  repeated=[[[4,1],[2]]].first().first().sorted().last().add(2);
  order=""; calls=0;
  computed={order=cat(order,"S"); [{"a":1}]}.first().set_key("b",{order=cat(order,"V"); calls=num_add(calls,1); 2});
  invalid_effects=0;
  invalid={invalid_effects=num_add(invalid_effects,1); [" a "]}.first({invalid_effects=num_add(invalid_effects,1); 1}).trim();
  return([
   " a : b ".split(/:/).first().trim().uppercase(),
   [" A "," B "].last().trim().lowercase(),
   [[3,1],[2]].first().sorted().last().add(4),
   [{"b":2,"a":1}].first().sorted_keys().last().uppercase(),
   [2,3].last().mul(4),
   [].first().trim(),copied_array,copied_hash,repeated,computed,order,calls,
   nested,saved,rows,invalid,invalid_effects,[[3,1]].first().min(),[3].first().min(2),
   [[3,1],[2]].first().copy().sorted().last().add(4),
   [{"b":2,"a":1}].first().copy().sorted_keys().last().uppercase()
  ]);
 }
"""
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    expected = Any["A", "b", 7, "B", 12, nothing, Any[3,1], Dict("a"=>1,"b"=>2), 6,
        Dict("a"=>1,"b"=>2), "SV", 1, Any[Any[3,1],Any[2]], Any[Any[3,1],Any[2]],
        Any[Dict("a"=>1,"b"=>2)], nothing, 0, 1, 2, 7, "B"]
    @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value == expected
    @test execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "selected-value-receivers.spec") == expected
    host = Module(gensym(:SelectedValueGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "selected-value-receivers.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    @test Base.invokelatest(getfield(parser, :execute), "x") == expected
end
