function _signed_array_compiled(action)
    source = "Top::\n /x/\n E { $action }\n"
    return compile_spec(parse_spec_with_staged_user_function_definitions(source))
end

@testset "Signed array selectors" begin
    cases = [
        (
            "items = [10,20,30]; return([items[-1],items[-2],items[-3],items[-4]])",
            Any[30, 20, 10, nothing],
        ),
        (
            "pick = {|items| return(items[-1]) }; return(pick([10,20,30]))",
            30,
        ),
        (
            "items = [10,20,30]; saved = (items[-2] = 99); items[0] = 7; return([items,saved])",
            Any[Any[7,99,30], Any[10,99,30]],
        ),
        (
            "cb = {|| document = {\"rows\":[[1],[2,3]]}; document[\"rows\"][-1][-2] = 99; return(document) }; return(cb())",
            Dict{String,Any}("rows" => Any[Any[1], Any[99,3]]),
        ),
        (
            "items = [10]; items[1] = 20; keys = {\"-1\":7}; keys[\"-1\"] = 8; return([items,keys[\"-1\"]])",
            Any[Any[10,20], 8],
        ),
        (
            "items = [10,20,30]; index = \"-1\"; return([items[-1.0],items[index]])",
            Any[nothing, nothing],
        ),
        (
            "items = [10,20]; items[-1] = { items[2] = 30; 99 }; return(items)",
            Any[10,20,99],
        ),
    ]
    for (action, expected) in cases
        compiled = _signed_array_compiled(action)
        @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value == expected
        @test execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), "x", "signed-array.spec",
        ) == expected
    end

    compiled = _signed_array_compiled(cases[4][1])
    host = Module(gensym(:SignedArrayGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "signed-array.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    @test Base.invokelatest(getfield(parser, :execute), "x") == cases[4][2]

    function diagnostic(action)
        compiled = _signed_array_compiled(action)
        failure = try
            runtime_execute(LinkedSpecRuntimeEngine(compiled), "x")
            nothing
        catch error
            error
        end
        @test failure isa RuntimeInterpreterException
        return to_json(failure.diagnostic)
    end

    underflow = diagnostic("items = [[1]]; items[-1][-2] = 9")
    @test underflow["code"] == "nested_write_array_underflow"
    @test (underflow["index"], underflow["length"], underflow["resolved_index"]) == (-2, 1, -1)
    @test underflow["path"] == Any[-1]
    @test underflow["segment_index"] == 1
    @test underflow["source_span"]["unit"] == "unicode_scalar"

    for action in (
        "missing[-1] = 9",
        "document = {}; document[\"rows\"][-1] = 9",
        "items = []; items[0][-1] = 9",
    )
        missing = diagnostic(action)
        @test missing["code"] == "nested_write_segment_invalid"
        @test missing["reason"] == "negative_integer"
    end
    wrong_kind = diagnostic("items = undef; items[-1] = 9")
    @test wrong_kind["code"] == "nested_write_kind_conflict"
    invalid = diagnostic("items = [1]; items[-2][true] = 9")
    @test invalid["code"] == "nested_write_segment_invalid"
    @test invalid["segment_index"] == 1
end
