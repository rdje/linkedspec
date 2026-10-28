module JuliaNamedMarkNumberResults
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
    error("unexpected named Number fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:NamedMarkNumberGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "named-mark-number.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "named-mark-number.spec",
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
    println("NAMED_MARK_NUMBER ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

function function_fence(source, helper)
    actual = observe(source, "αβ:cat")
    println("NAMED_MARK_NUMBER_FENCE ", JSON3.write(actual))
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
("shared",read(joinpath(dirname(dirname(@__DIR__)),"tests","fixtures","named_mark_number_values.spec"),String),"αβ:cat"),
("producers",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(finish),mark_line(finish),mark_col(finish),capture_len_from(begin),capture_rest_len_from(begin),capture_until_cursor_len_from(begin),capture_len_between(begin,finish)])}
""","αβ:cat"),
("missing_producers",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(absent),mark_line(absent),mark_col(absent),capture_len_from(absent),capture_rest_len_from(absent),capture_until_cursor_len_from(absent),capture_len_between(absent,finish),capture_len_between(begin,absent)])}
""","αβ:cat"),
("symbolic_shadow",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);begin="finish";finish="begin";return([capture_len_between(begin,finish),mark_pos(begin),mark_pos(finish)])}
""","αβ:cat"),
("quoted_names",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos("finish"),capture_len_between("begin","finish")])}
""","αβ:cat"),
("evaluated_name",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_pos(cat("fin","ish")))}
""","αβ:cat"),
("legacy_bound",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);p=mark_pos(finish);order="";a=p.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=p.take({order=cat(order,"T");1});c=p.add(0).set_key({order=cat(order,"X");"k"},{order=cat(order,"Y");1});return([a,b,c,order])}
""","αβ:cat"),
("snapshot_bound",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);order="";p=mark_pos(finish);snapshot=p.cat({order=cat(order,"S");"!"});clear_mark(finish);return([snapshot,mark_pos(finish),mark_pos(begin),order])}
""","αβ:cat"),
("direct_mark_pos",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_pos(finish).coalesce(0).cat("!"))}
""","αβ:cat"),
("direct_mark_line",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_line(finish).coalesce(0).cat("!"))}
""","αβ:cat"),
("direct_mark_col",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_col(finish).coalesce(0).cat("!"))}
""","αβ:cat"),
("direct_capture_len_from",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_len_from(begin).coalesce(0).cat("!"))}
""","αβ:cat"),
("direct_capture_until_cursor_len_from",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_until_cursor_len_from(begin).coalesce(0).cat("!"))}
""","αβ:cat"),
("direct_capture_rest_len_from",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_rest_len_from(begin).coalesce(0).cat("!"))}
""","αβ:cat"),
("direct_capture_len_between",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_len_between(begin,finish).coalesce(0).cat("!"))}
""","αβ:cat"),
("direct_legacy",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);order="";a=mark_pos(finish).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=mark_pos(finish).take({order=cat(order,"T");1});return([a,b,order])}
""","αβ:cat"),
("other_label",raw"""Top::
 -> Other .push
 LX {return(copy(Top))}
Other:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Other[2] {mark_input_start(left);mark_input_end(right);return([mark_pos(right).coalesce(0).sub(1),mark_line(right).coalesce(0).add(1),mark_col(right).coalesce(0).cat("!"),capture_len_from(left).coalesce(0).cat(":tail").split(":")[-1].uppercase(),capture_rest_len_from(left).coalesce(0).add(1),capture_until_cursor_len_from(left).coalesce(0).sub(1),capture_len_between(left,right).coalesce(0).add(1)])}
""","αβ:cat"),
("partial_shared",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(finish).coalesce(0).sub(1),mark_line(finish).coalesce(0).add(1),mark_col(finish).coalesce(0).cat("!"),capture_len_from(begin).coalesce(0).cat(":tail").split(":")[-1].uppercase(),capture_rest_len_from(begin).coalesce(0).add(1),capture_until_cursor_len_from(begin).coalesce(0).sub(1),capture_len_between(begin,finish).coalesce(0).add(1)])}
""","αβ:catTAIL"),
("zero_missing_reversed",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);order="";a=mark_pos(begin).coalesce({order=cat(order,"Z");9}).add(1);b=capture_len_between(begin,begin).coalesce({order=cat(order,"E");9}).add(1);c=mark_pos(absent).coalesce({order=cat(order,"F");7}).add(1);d=capture_len_between(finish,begin).coalesce(9).add(1);return([a,b,c,d,order])}
""","αβ:cat"),
("function_mark_pos",raw"""fn forbidden(){return(mark_pos(finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
""","αβ:cat"),
("function_mark_line",raw"""fn forbidden(){return(mark_line(finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
""","αβ:cat"),
("function_mark_col",raw"""fn forbidden(){return(mark_col(finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
""","αβ:cat"),
("function_capture_len_from",raw"""fn forbidden(){return(capture_len_from(begin).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
""","αβ:cat"),
("function_capture_until_cursor_len_from",raw"""fn forbidden(){return(capture_until_cursor_len_from(begin).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
""","αβ:cat"),
("function_capture_rest_len_from",raw"""fn forbidden(){return(capture_rest_len_from(begin).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
""","αβ:cat"),
("function_capture_len_between",raw"""fn forbidden(){return(capture_len_between(begin,finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
""","αβ:cat"),
("literal_callback_all",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);cb={||return([mark_pos(finish).coalesce(0).cat("!"),mark_line(finish).coalesce(0).cat("!"),mark_col(finish).coalesce(0).cat("!"),capture_len_from(begin).coalesce(0).cat("!"),capture_until_cursor_len_from(begin).coalesce(0).cat("!"),capture_rest_len_from(begin).coalesce(0).cat("!"),capture_len_between(begin,finish).coalesce(0).cat("!")])};return(cb())}
""","αβ:cat"),
("registered_callback",raw"""fn apply(callback: codeblock){return(callback())}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(apply(){return(mark_pos(finish).coalesce(0).cat("!"))})}
""","αβ:cat"),
("callback_write_read_scope",raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);cb={||mark_input_end(inside);return([mark_pos(inside),mark_pos(finish)])};result=cb();return([result,mark_pos(inside),mark_pos(finish)])}
""","αβ:cat"),
("callback_cross_rule_scope",raw"""Top:: I {a=call(First);b=call(Second);return([a,b])}
First:: I {cb={||mark_input_end(shared);return(mark_pos(shared))};a=cb();return([a,mark_pos(shared)])}
Second:: I {cb={||return(mark_pos(shared))};a=cb();return([a,mark_pos(shared)])}
""","x"),
("dynamic_invocation",raw"""Top::
 I {reader=call(First);mark_input_start(shared);a=reader();mark_input_end(shared);b=reader();return([a,b])}
First::
 I {mark_input_end(shared);return({||return(mark_pos(shared))})}
""","αβ:cat"),
    ]
end

@testset "Julia named Number values and dynamic caller marks" begin
    @testset "Ordinary values roots and callback scope" begin
        expected = Dict{String,Any}(
            "shared" => JSON3.read(read(joinpath(dirname(dirname(@__DIR__)), "tests", "fixtures", "named_mark_number_values.json"), String), Any),
            "producers" => JSON3.read(raw"""[[6, 1, 7, 3, 6, 6, 6]]""", Any),
            "missing_producers" => JSON3.read(raw"""[[null, null, null, null, null, null, null, null]]""", Any),
            "symbolic_shadow" => JSON3.read(raw"""[[6, 0, 6]]""", Any),
            "quoted_names" => JSON3.read(raw"""[[6, 6]]""", Any),
            "evaluated_name" => JSON3.read(raw"""[6]""", Any),
            "legacy_bound" => JSON3.read(raw"""[[6, [], null, "KVT"]]""", Any),
            "snapshot_bound" => JSON3.read(raw"""[["6!", null, 0, "S"]]""", Any),
            "direct_legacy" => JSON3.read(raw"""[[6, [], "KVT"]]""", Any),
            "other_label" => JSON3.read(raw"""[[5, 2, "7!", "TAIL", 7, 5, 7]]""", Any),
            "partial_shared" => JSON3.read(raw"""[[9, 2, "11!", "TAIL", 11, 5, 11]]""", Any),
            "zero_missing_reversed" => JSON3.read(raw"""[[1, 1, 8, 10, "F"]]""", Any),
            "literal_callback_all" => JSON3.read(raw"""[["6!", "1!", "7!", "3!", "6!", "6!", "6!"]]""", Any),
            "callback_write_read_scope" => JSON3.read(raw"""[[[6, 6], 6, 6]]""", Any),
            "callback_cross_rule_scope" => JSON3.read(raw"""[[1, 1], [null, null]]""", Any),
            "dynamic_invocation" => JSON3.read(raw"""[0, 6]""", Any),
            "direct_mark_pos" => JSON3.read(raw"""["6!"]""", Any),
            "direct_mark_line" => JSON3.read(raw"""["1!"]""", Any),
            "direct_mark_col" => JSON3.read(raw"""["7!"]""", Any),
            "direct_capture_len_from" => JSON3.read(raw"""["3!"]""", Any),
            "direct_capture_until_cursor_len_from" => JSON3.read(raw"""["6!"]""", Any),
            "direct_capture_rest_len_from" => JSON3.read(raw"""["6!"]""", Any),
            "direct_capture_len_between" => JSON3.read(raw"""["6!"]""", Any),
        )
        for (id, source, input) in cases()
            haskey(expected, id) && check(source, input, expected[id])
        end
    end
    @testset "Specific pure-function and registered callback fences" begin
        for (id, source, input) in cases()
            if startswith(id, "function_") || id == "registered_callback"
                helper = id == "registered_callback" ? "mark_pos" : id[length("function_") + 1:end]
                function_fence(source, helper)
            end
        end
    end
end
end
