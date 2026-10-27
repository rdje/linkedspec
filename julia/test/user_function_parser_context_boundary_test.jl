# TYPE-REFERENCE-BOOK.1.2.23.3.29.2.6.4 — parser calls and public gap readers.
function strict_function_context_equal(actual, expected)
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
            all(strict_function_context_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_function_context_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected context fixture type $(typeof(expected))")
end
function function_context_source(definitions, action, item)
    return "$definitions\nList::\n @capture_gaps\n I {set(rows,array())}\n -> Item[word] {$action}\n LX {return(copy(rows))}\nItem:\n word=/[^,;]+/\n I {$item}\n"
end
function function_context_routes(source, input)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    host = Module(gensym(:FunctionContextGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "function-parser-context.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    return (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "plan" => () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), input, "function-parser-context.spec"),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
end
function reject_function_context(source, input, helper)
    for (route, operation) in function_context_routes(source, input)
        actual = nothing
        error_text = try
            actual = operation()
            ""
        catch failure
            sprint(showerror, failure)
        end
        println("FUNCTION_CONTEXT ", JSON3.write(Dict("route"=>route,"helper"=>helper,"actual"=>actual,"error"=>error_text)))
        @test occursin("parser-state helper", error_text) && occursin(helper, error_text)
    end
end
function check_function_context_values(source, input, expected)
    for (route, operation) in function_context_routes(source, input)
        @test strict_function_context_equal(operation(), expected)
    end
end
@testset "Julia pure function parser context boundary" begin
    @testset "Child parser calls" begin
        reject_function_context("fn selected(){return(call(Child))}\nTop:: I {return(selected())}\nChild: I {return(\"child\")}\n", "x", "call")
    end
    @testset "Public gap context" begin
        for helper in ("gap_text", "gap_kind", "gap_span", "entry_slot")
            source = function_context_source("fn selected(){return($helper())}", "push(rows,selected())", "return(entry_text())")
            reject_function_context(source, "a,b", helper)
        end
    end
    @testset "Incoming child slot" begin
        source = function_context_source("fn selected(){return(entry_slot())}", "push(rows,call(Item))", "return(selected())")
        reject_function_context(source, "a,b", "entry_slot")
    end
    @testset "Explicit caller child gap and slot arguments" begin
        check_function_context_values("fn upper(text){return(text.uppercase())}\nTop:: I {return(upper(call(Child)))}\nChild: I {return(\"child\")}\n", "x", "CHILD")
        source = function_context_source("fn selected(text,kind,span){return([text.uppercase(),kind,span])}", "push(rows,selected(gap_text(),gap_kind(),gap_span()))", "return(entry_text())")
        check_function_context_values(source, "a,b", JSON3.read(raw"""[["","prefix",{"source_id":"input","start":0,"end":0,"provenance":"gap"}],[",","interstitial",{"source_id":"input","start":1,"end":2,"provenance":"gap"}]]""", Any))
        source = function_context_source("fn identify(slot){return(slot)}", "push(rows,call(Item))", "return(identify(entry_slot()))")
        slot = Dict("target_rule"=>"Item","regex_index"=>0,"slot_id"=>"word","selector_kind"=>"named","authored_selector"=>"word")
        check_function_context_values(source, "a,b", Any[slot, slot])
    end
end
