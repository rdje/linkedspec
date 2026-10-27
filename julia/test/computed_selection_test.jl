# TYPE-REFERENCE-BOOK.1.2.23.3.24.4 — ordinary computed bracket selection.
function strict_selection_equal(actual, expected)
    if expected isa Bool
        return actual === expected
    elseif expected isa Number
        return actual isa Number && !(actual isa Bool) && actual == expected
    elseif expected === nothing
        return actual === nothing
    elseif expected isa AbstractString
        return actual isa AbstractString && actual == expected
    elseif expected isa AbstractVector
        return actual isa AbstractVector && length(actual) == length(expected) &&
            all(strict_selection_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_selection_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected fixture type $(typeof(expected))")
end

function check_computed_selection(source, expected)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    host = Module(gensym(:ComputedSelectionGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "computed-selection.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    observations = Pair{String,Any}[]
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value,
        "plan" => () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), "x", "computed-selection.spec"),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"),
    )
        actual = try
            operation()
        catch error
            Dict("unexpected_error" => sprint(showerror, error))
        end
        push!(observations, route => actual)
    end
    println("COMPUTED_SELECTION_OBSERVATIONS ", JSON3.write(Dict(observations)))
    for (route, actual) in observations
        @testset "$route" begin
            @test strict_selection_equal(actual, expected)
        end
    end
end

@testset "Julia computed selection" begin
    @testset "Parser boundaries and scalar spans" begin
        @test parse_action_expression("\"x\".?") isa ActionRawExpr
        raw_receiver = parse_action_expression("@host.trim()")
        @test raw_receiver.receiver isa ActionRawExpr
        @test parse_action_expression("items[0]") isa ActionIndexedVarExpr
        @test parse_action_expression("(array(\"a\"))[0]") isa ActionRawExpr
        chain = parse_action_expression("[\"🙂\",\"b\"][-1].uppercase()")
        selected = chain.receiver
        @test selected.source == "[\"🙂\",\"b\"][-1]"
        @test selected.source_span.start == 0
        @test selected.source_span.stop == length(selected.source)
    end
    @testset "Unchanged complete target" begin
        root = dirname(dirname(@__DIR__))
        source = read(joinpath(root,"tests","fixtures","computed_selection_values.spec"),String)
        expected = JSON3.read(read(joinpath(root,"tests","fixtures","computed_selection_values.json"),String),Any)
        check_computed_selection(source, expected)
    end
    @testset "Existing data-call kind guards" begin
        check_computed_selection(raw"""Top:: I {
            order="";
            a=array(false)[0].take({order=cat(order,"A");1});
            b=array([1])[0].set_key({order=cat(order,"K");"a"},{order=cat(order,"V");2});
            c={order=cat(order,"S");"a,b"}.split(",").copy({order=cat(order,"A");1});
            return([a,b,c,order]);
        }""", Any[nothing,nothing,nothing,""])
    end
    @testset "Function scopes snapshots and repeated bridges" begin
        check_computed_selection(raw"""fn echo(value) {return(value)}
fn select(text) {position=-1;return(echo(text.split(","))[position].uppercase())}
Top:: I {
    position=9;order="";source=["old","tail"];
    selected=echo({order=cat(order,"S");source})[{order=cat(order,"I");source=["new"];-1}].uppercase().cat({order=cat(order,"C");"!"});
    return([selected,order,source,select("a,b"),position,
        [undef][0].coalesce([{"items":["a","b"]}])[0]["items"][-1].uppercase()]);
}""", Any["TAIL!","SIC",Any["new"],"B",9,"B"])
    end
    @testset "Scoped with kind guards" begin
        check_computed_selection(raw"""Top:: I {
            order="";
            a=array(false)[0].with() {return(value)}.take({order=cat(order,"A");1});
            b=array([2,1])[0].with() {return(value)}.sorted()[0].add(2);
            return([a,b,order]);
        }""", Any[nothing,3,""])
    end
    @testset "Existing bound-call result policy" begin
        check_computed_selection(raw"""Top:: I {
            thunk={|| return([false,["tail"]])};
            return([thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count()]);
        }""", Any[false,"TAIL",0,0])
    end
    @testset "Regex split index and Unicode String methods" begin
        check_computed_selection(raw"""Top:: I {return(["αXβ".split(/[x]/i)[-1].uppercase(),split("aXb",/[x]/i)[1].uppercase()])}""", Any["Β","B"])
    end
end
