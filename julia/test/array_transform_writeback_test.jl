function _array_transform_compiled(body)
    source = "Top::\n /x/\n E { $body }\n"
    return compile_spec(parse_spec_with_staged_user_function_definitions(source))
end

@testset "Standalone array transform writeback" begin
    compiled = _array_transform_compiled(raw"""
        items=["a:b","a:a"]; saved=copy(items); calls=0;
        split_each(items,{ calls=num_add(calls,1); ":" }); split_snapshot=copy(items);
        filter_match(items,{ calls=num_add(calls,1); "^a$" }); filter_snapshot=copy(items);
        uniq(items); unique_snapshot=copy(items); items[0]="z";
        source=["b:b","a:a","b:b"];
        pure_split=split_each(source,":"); pure_filter=filter_match(source,/^a/);
        pure_unique=uniq(source); chain=source.split_each(":").filter_match(/^a$/).uniq();
        typed=[2,"2","x"]; filter_match(typed,/^2$/); uniq(typed);
        split_each(absent_split,":"); filter_match(absent_filter,/x/); uniq(absent_unique);
        return([items,saved,split_snapshot,filter_snapshot,unique_snapshot,calls,
            source,pure_split,pure_filter,pure_unique,chain,typed,
            absent_split,absent_filter,absent_unique]);
    """)
    expected = Any[
        Any["z"], Any["a:b", "a:a"], Any["a", "b", "a", "a"],
        Any["a", "a", "a"], Any["a"], 2, Any["b:b", "a:a", "b:b"],
        Any["b", "b", "a", "a", "b", "b"], Any["a:a"], Any["b:b", "a:a"],
        Any["a"], Any[2], Any[], Any[], Any[],
    ]
    @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value == expected
    @test execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
        "x", "transform-writeback.spec") == expected
    host = Module(gensym(:ArrayTransformGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "transform-writeback.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    @test Base.invokelatest(getfield(parser, :execute), "x") == expected

    for statement in ("split_each(target,\":\")", "filter_match(target,/x/)", "uniq(target)")
        wrong = _array_transform_compiled("target=7; $statement; return(target)")
        failure = try
            runtime_execute(LinkedSpecRuntimeEngine(wrong), "x")
            nothing
        catch error
            error
        end
        @test failure isa RuntimeInterpreterException
        @test occursin("binding_kind_mismatch identifier=target expected_kind=array actual_kind=scalar",
            sprint(showerror, failure))
    end
end
