module JuliaActiveEdgeBodyCandidates
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
    error("unexpected active-edge fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:ActiveEdgeGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "active-edge-body.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), input, "active-edge-body.spec"),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
        result[route] = try
            operation()
        catch failure
            Dict("unexpected_error" => sprint(showerror, failure))
        end
    end
    return result
end

function check(source, input, expected)
    actual = observe(source, input)
    println("ACTIVE_EDGE ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native","restored","plan","fresh"])
    for route in ("native","restored","plan","fresh")
        @test strict_equal(actual[route], expected)
    end
end

carrier(head, action) = """Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>$head)/
 /:/
 /(?<token>cat)/
 -> Value[2] {$action}
"""

@testset "Julia outgoing-edge body candidates" begin
    @testset "wildcard body eligibility" begin
        check(carrier("..", "return(\"BODY\")"), "αβ:cat", Any["BODY"])
    end
    @testset "literal control" begin
        check(carrier("αβ", "return(\"BODY\")"), "αβ:cat", Any["BODY"])
    end
    for mode in ("", "|")
        @testset "reverse duplicate edge priority $mode" begin
            source = """Top::
 -> Value .push
 LX {return(copy(Top))}
Value:$mode
 /H/
 /a/
 /a/
 -> Value[2] {return(2)}
 -> Value[1] {return(1)}
"""
            check(source, "Ha", Any[2])
        end
    end
    @testset "earliest start before edge order" begin
        check(raw"""Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /H/
 /b/
 /a/
 -> Value[1] {return("B")}
 -> Value[2] {return("A")}
""", "Hab", Any["A"])
    end
    @testset "cross-target parent exclusion" begin
        check(raw"""Top::
 /./
 -> Second {return("second")}
 -> First {return("first")}
First: /a/
Second: /a/
""", "a", "second")
    end
    @testset "no eligible selected-first gap hook" begin
        check(raw"""Top::
 /./
 @capture_gaps
 -> Value {return("edge")}
 LS {return("wrong")}
 LX {return("miss")}
Value: /cat/
""", "x", "miss")
    end
    @testset "captures and Unicode source positions" begin
        check(
            carrier("..", raw"""mark_match_start(begin);mark_match_end(finish);
return([match_text(),match_group(0),match_named(token),mark_pos(begin),mark_pos(finish),entry_named(head)])"""),
            "αβ:cat", Any[Any["cat", "cat", "cat", 3, 6, "αβ"]],
        )
    end
    @testset "complete boundary catalog" begin
        check(raw"""Top:: I {return(capture_until_boundary("Landmark"))}
Landmark:
 /END/
 /!/
 -> Landmark[1] {return(1)}
""", "bodyEND!", "body")
    end
    @testset "selected edge gap span" begin
        source = replace(
            carrier("..", "return([gap_text(),gap_span(),match_text()])"),
            " -> Value[2]" => " @capture_gaps\n -> Value[2]"; count = 1,
        )
        check(source, "αβ:cat", Any[Any[
            ":", Dict("source_id"=>"input", "start"=>2, "end"=>3, "provenance"=>"gap"), "cat",
        ]])
    end
    @testset "established duplicate contract fixtures" begin
        root = dirname(dirname(@__DIR__))
        contract = JSON3.read(read(joinpath(
            root, "capability_conformance", "duplicate_regex_slot_identity_contract.json",
        ), String), Dict{String,Any})
        for row in contract["fixtures"]
            check(row["source"], row["input"], row["expected_result"])
        end
    end
    @testset "family cursor ownership" begin
        check("Top:: /x/ -> Top {return(\"hit\")}\n", "prefix x", "hit")
        check("Top::AND /x/ -> Top {return(\"hit\")}\n", "prefix x", nothing)
    end
    @testset "native/generated in-memory slot traces" begin
        compiled = compile_spec(parse_spec_with_staged_user_function_definitions(
            carrier("..", "return(\"BODY\")"),
        ))
        @test length(compiled.rules_by_label["Value"].regex_patterns) == 3
        for generated in (false, true)
            trace = LinkedSpecTraceEmitter(
                trace_config_enabled(LinkedSpecTraceHigh); stdout_io = IOBuffer(),
            )
            actual = if generated
                execute_generated_parser_v2(
                    compiled, build_generated_rule_plan(compiled), "αβ:cat",
                    "active-edge-body.spec"; trace = trace,
                )
            else
                runtime_execute(LinkedSpecRuntimeEngine(compiled), "αβ:cat"; trace = trace).value
            end
            selected = [event.details for event in trace_events(trace) if
                event.topic == "julia_runtime:regex_slot_selected" &&
                occursin("rule_label=Value ", event.details)]
            println("ACTIVE_EDGE_TRACE ", JSON3.write(Dict(
                "generated"=>generated, "value"=>actual, "slots"=>selected,
            )))
            @test strict_equal(actual, Any["BODY"])
            @test length(selected) == 1
            @test length(selected) == 1 && occursin("target_rule=Value regex_index=2", only(selected))
        end
    end
end
end
