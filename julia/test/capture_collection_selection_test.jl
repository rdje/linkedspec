# TYPE-REFERENCE-BOOK.1.2.23.3.25.4 — readonly capture result composition.
function strict_capture_selection_equal(actual, expected)
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
            all(strict_capture_selection_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_capture_selection_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected capture fixture type $(typeof(expected))")
end

function check_capture_selection(source, input, expected)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    host = Module(gensym(:CaptureSelectionGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "capture-collection-selection.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    observations = Pair{String,Any}[]
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "plan" => () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), input, "capture-collection-selection.spec"),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
        actual = try
            operation()
        catch error
            Dict("unexpected_error" => sprint(showerror, error))
        end
        push!(observations, route => actual)
    end
    println("CAPTURE_SELECTION_OBSERVATIONS ", JSON3.write(Dict(observations)))
    for (route, actual) in observations
        @testset "$route" begin
            @test strict_capture_selection_equal(actual, expected)
        end
    end
end

@testset "Julia capture collection selection" begin
    @testset "Unchanged frozen target" begin
        root = dirname(dirname(@__DIR__))
        source = read(joinpath(root,"tests","fixtures","capture_collection_selection_values.spec"),String)
        expected = JSON3.read(read(joinpath(root,"tests","fixtures","capture_collection_selection_values.json"),String),Any)
        check_capture_selection(source, "name=Alpha", expected)
    end
    @testset "Aliases and with reject incompatible operands" begin
        check_capture_selection(raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>name)/
 /=/
 /(?<value>Alpha)/
 -> Value[1] {separator=match_text()}
 -> Value[2] {
  order="";
  a=match_groups()[-1].with() {return(value)}.take({order=cat(order,"A");1});
  b=entry_named_map()["head"].set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});
  c=match_named_map()["value"].take({order=cat(order,"C");1});
  return([a,b,c,order]);
 }""", "name=Alpha", Any[Any[nothing,nothing,nothing,""]])
    end
    @testset "String kinds compaction and static helpers" begin
        check_capture_selection(raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>0)(?<empty>)(?<missing>x)?/
 /=/
 /(?<value>Alpha)(?<empty>)(?<missing>x)?/
 -> Value[1] {separator=match_text()}
 -> Value[2] {
  entry_groups={|| return(["shadow"]) };
  match_map={|| return({"value":"shadow"}) };
  return([entry_groups()[0],entry_groups()[1],entry_groups()[2].coalesce("missing"),entry_map()["empty"],match_groups()[-1],match_map()["value"],entry_named_map()["head"],match_named_map()["empty"]]);
 }""", "0=Alpha", Any[Any["0","","missing","","","Alpha","0",""]])
    end
    @testset "Missing captures versus legacy source counts" begin
        check_capture_selection(raw"""Top:: I {
 thunk={|| return([false,["tail"]])};
 return([entry_groups()[0].count(),entry_map()["head"].count(),match_groups()[0].count(),match_map()["value"].count(),entry_named_map()["head"].count(),match_named_map()["value"].count(),thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count(),cursor_rest()[0].count(),flat([1])[9].count()]);
}""", "x", Any[nothing,nothing,nothing,nothing,nothing,nothing,false,"TAIL",0,0,0,0])
    end
end
