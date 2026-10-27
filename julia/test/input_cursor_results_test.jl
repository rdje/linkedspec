# TYPE-REFERENCE-BOOK.1.2.23.3.27.4 — readonly input/cursor result composition.
function strict_input_cursor_results_equal(actual, expected)
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
            all(strict_input_cursor_results_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_input_cursor_results_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected reader fixture type $(typeof(expected))")
end

function check_input_cursor_results(source, input, expected)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    host = Module(gensym(:InputCursorGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "input-cursor-results.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    observations = Pair{String,Any}[]
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "plan" => () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), input, "input-cursor-results.spec"),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
        actual = try
            operation()
        catch error
            Dict("unexpected_error" => sprint(showerror, error))
        end
        push!(observations, route => actual)
    end
    println("INPUT_CURSOR_OBSERVATIONS ", JSON3.write(Dict(observations)))
    for (route, actual) in observations
        @testset "$route" begin
            @test strict_input_cursor_results_equal(actual, expected)
        end
    end
end

function check_input_cursor_action(action, expected)
    source = "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /name/\n /=/\n /Alpha/\n -> Value[2] {" * action * "}\n"
    check_input_cursor_results(source, "name=Alpha", expected)
end

@testset "Julia input cursor results" begin
 @testset "Unchanged frozen target" begin
  root=dirname(dirname(@__DIR__))
  source=read(joinpath(root,"tests","fixtures","input_cursor_result_values.spec"),String)
  expected=JSON3.read(read(joinpath(root,"tests","fixtures","input_cursor_result_values.json"),String),Any)
  check_input_cursor_results(source,"name=Alpha",expected)
 end
 @testset "With actual kinds and outer scope" begin
  check_input_cursor_action(raw"""
 order="";value="outer";
 a=input_text().with() {return(value)}.take({order=cat(order,"A");1});
 b=input_len().with() {return(value)}.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
 c=input_text().with() {order=cat(order,"W");return(["a","b"])}.last().uppercase();
 d=input_len().with() {return({"k":[false]})}.sorted_values().first().first();
 return([a,b,c,d,order,value]);
""",JSON3.read(raw"""[[null,null,"B",false,"W","outer"]]""",Any))
 end
 @testset "Source order defaults Number indices and named controls" begin
  check_input_cursor_action(raw"""
 order="";start=5;width=5;
 result=input_slice({order=cat(order,"S");start},{order=cat(order,"W");width}).coalesce({order=cat(order,"F");"bad"}).cat({order=cat(order,"C");start=0;width=4;"!"});
 items=["zero","one"];index=input_len().coalesce({order=cat(order,"F");7}).sub(10);items[index]="updated";
 a=input_text();b=input_len();c=cursor_rest();d=cursor_rest_len();
 return([result,order,start,width,items,input_slice(0,0).coalesce("late").cat("!"),a.coalesce("late").split("=")[-1].uppercase(),b.coalesce(0).add(1),c.coalesce("late").cat("!"),d.coalesce(7).add(1)]);
""",JSON3.read(raw"""[["Alpha!","SWC",0,4,["updated","one"],"!","ALPHA",11,"!",1]]""",Any))
 end
 @testset "Reader counts and legacy malformed bound flat results" begin
  check_input_cursor_action(raw"""
 thunk={|| return([false,["tail"]])};
 return([input_text().count(),input_len().count_keys(),input_text().with() {return(value)}.count(),thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count(),flat([1])[9].count(),input_text("ignored").count(),input_slice(0).count()]);
""",JSON3.read(raw"""[[null,null,null,false,"TAIL",0,0,0,0,0]]""",Any))
 end
end
