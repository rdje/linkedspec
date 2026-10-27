# TYPE-REFERENCE-BOOK.1.2.23.3.29.2.4 — accepted pure-function boundary.
function function_state_source(definitions, action)
    return "$definitions\nTop::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {$action}\n"
end
function function_state_routes(source)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    host = Module(gensym(:FunctionStateGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "function-state-boundary.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    return (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), "name=Alpha").value,
        "plan" => () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), "name=Alpha", "function-state-boundary.spec"),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "name=Alpha"),
    )
end
function reject_function_state_source(source, helper)
    for (route, operation) in function_state_routes(source)
        actual = nothing
        error_text = try
            actual = operation()
            ""
        catch failure
            sprint(showerror, failure)
        end
        println("FUNCTION_STATE ", JSON3.write(Dict("route" => route, "helper" => helper, "actual" => actual, "error" => error_text)))
        @test occursin("parser-state helper", error_text) && occursin(helper, error_text)
    end
end
@testset "Julia pure function parser state boundary" begin
    @testset "Capture collection and group readers" begin
        for helper in ("entry_groups", "match_groups", "entry_map", "match_map", "entry_named_map", "match_named_map", "entry_group", "match_group")
            argument = endswith(helper, "group") ? "0" : ""
            source = function_state_source("fn forbidden(){return($helper($argument))}", "return(forbidden())")
            reject_function_state_source(source, helper)
        end
    end
    @testset "Input position mark capture and cursor roles" begin
        for (helper, expression) in (("input_text", "input_text()"), ("cursor_pos", "cursor_pos()"), ("entry_start_pos", "entry_start_pos()"), ("mark_pos", "mark_pos(point)"), ("capture_slice", "capture_slice()"), ("save_cursor", "save_cursor(point)"))
            source = function_state_source("fn forbidden(){return($expression)}", "return(forbidden())")
            reject_function_state_source(source, helper)
        end
    end
    @testset "Nested and discarded parser reads" begin
        source = function_state_source("fn inner(){return(entry_groups())}\nfn outer(){match_map();return(inner())}", "return(outer())")
        reject_function_state_source(source, "match_map")
    end
    @testset "Explicit caller values locals and prefix names" begin
        source = function_state_source("fn entry_custom(text){local_text=text.uppercase();return(local_text)}\nfn capture_custom(text){return(entry_custom(text))}", "return([capture_custom(entry_group(0)),capture_custom(match_named(\"value\")),entry_groups().last().uppercase(),match_map()[\"value\"].uppercase()])")
        for (route, operation) in function_state_routes(source)
            @test operation() == Any[Any["NAME", "ALPHA", "NAME", "ALPHA"]]
        end
    end
end
