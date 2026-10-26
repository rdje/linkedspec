@testset "Receiver copy arity before effects" begin
    source = raw"""Top:: /x/ E {
      effects=0;
      invalid={effects=num_add(effects,1); [["a"]]}.first().copy({effects=num_add(effects,1); 1});
      invalid_direct={effects=num_add(effects,1); ["b"]}.copy({effects=num_add(effects,1); 1});
      valid_effects=0; original=[["a"]];
      copied={valid_effects=num_add(valid_effects,1); original}.first().copy();
      copied+="b";
      return([invalid,invalid_direct,effects,copied,original,valid_effects,"x".copy().uppercase(),missing.copy()]);
    }
    """
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    expected = Any[nothing,nothing,0,Any["a","b"],Any[Any["a"]],1,"X",nothing]
    @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value == expected
    @test execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "receiver-copy-arity.spec") == expected
    host = Module(gensym(:ReceiverCopyArityGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "receiver-copy-arity.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    @test Base.invokelatest(getfield(parser, :execute), "x") == expected
end
