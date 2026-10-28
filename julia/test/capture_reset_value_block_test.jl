module JuliaCaptureResetValueBlocks
using LinkedSpecJulia, JSON3, Test

function strict_equal(actual, expected)
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
            all(strict_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected capture Number fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:CaptureResetGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "capture-reset-value-block.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "capture-reset-value-block.spec",
        ),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
        result[route] = try
            Dict("ok" => operation())
        catch failure
            Dict("error"=>sprint(showerror, failure), "class"=>string(nameof(typeof(failure))))
        end
    end
    return result
end

function check(source, input, expected)
    actual = observe(source, input)
    println("CAPTURE_RESET ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

function function_fence(source, helper)
    actual = observe(source, "αβ:cat")
    println("CAPTURE_RESET_FENCE ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        row = actual[route]
        expected_class = route in ("native", "restored") ?
            "RuntimeInterpreterException" : "GeneratedSourceException"
        @test get(row, "class", "") == expected_class &&
            all(occursin(part, get(row, "error", "")) for part in
                ("parser-state helper", "'$helper'", "not supported in user functions"))
    end
end

function cases()
    return [
        ("without_reset", raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"""),
        ("standalone", raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});start_capture_slice();order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"""),
        ("inside", read(joinpath(dirname(dirname(@__DIR__)), "tests", "fixtures", "capture_reset_value_block_values.spec"), String)),
        ("alias_inside", raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");capture_slice_here();"!"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"""),
        ("return_before", raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");return("!");start_capture_slice();order=cat(order,"T");"bad"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"""),
        ("return_after", raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");start_capture_slice();return("!");order=cat(order,"T");"bad"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"""),
        ("lazy_skip", raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.coalesce({order=cat(order,"S");start_capture_slice();"bad"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"""),
        ("direct_source", raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";snapshot=capture_rest_len().cat({order=cat(order,"S");start_capture_slice();"!"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"""),
        ("function_start_capture_slice", raw"""fn forbidden(){return("x".cat({start_capture_slice();"!"}))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {result=forbidden();return([result,capture_slice_pos()])}
"""),
        ("literal_start_capture_slice", raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {cb={||return("x".cat({start_capture_slice();"!"}))};result=cb();return([result,capture_slice_pos()])}
"""),
        ("registered_start_capture_slice", raw"""fn apply(callback: codeblock){return(callback())}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {result=apply(){return("x".cat({start_capture_slice();"!"}))};return([result,capture_slice_pos()])}
"""),
        ("function_capture_slice_here", raw"""fn forbidden(){return("x".cat({capture_slice_here();"!"}))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {result=forbidden();return([result,capture_slice_pos()])}
"""),
        ("literal_capture_slice_here", raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {cb={||return("x".cat({capture_slice_here();"!"}))};result=cb();return([result,capture_slice_pos()])}
"""),
        ("registered_capture_slice_here", raw"""fn apply(callback: codeblock){return(callback())}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {result=apply(){return("x".cat({capture_slice_here();"!"}))};return([result,capture_slice_pos()])}
"""),
    ]
end

@testset "Julia anonymous capture reset value blocks" begin
    @testset "Ordinary snapshot, lazy order and local returns" begin
        expected = Dict{String,Any}(
            "without_reset"=>[["4!",2,4,"SA"]],
            "standalone"=>[["4!",6,0,"SA"]],
            "inside"=>JSON3.read(read(joinpath(dirname(dirname(@__DIR__)),
                "tests","fixtures","capture_reset_value_block_values.json"), String), Any),
            "alias_inside"=>[["4!",6,0,"SA"]],
            "return_before"=>[["4!",2,4,"SA"]],
            "return_after"=>[["4!",6,0,"SA"]],
            "lazy_skip"=>[[4,2,4,"A"]],
            "direct_source"=>[["4!",6,0,"SA"]],
        )
        for (id, source) in cases()
            haskey(expected,id) && check(source,"αβ:cat",expected[id])
        end
    end
    @testset "Existing literal callback caller context" begin
        for (id, source) in cases()
            startswith(id,"literal_") && check(source,"αβ:cat",[["x!",6]])
        end
    end
    @testset "Pure function and registered callback authored helper fences" begin
        for (id, source) in cases()
            if startswith(id,"function_") || startswith(id,"registered_")
                function_fence(source,split(id,"_";limit=2)[2])
            end
        end
    end
end
end
