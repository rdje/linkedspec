module JuliaGapSlotRecordSelection
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
    error("unexpected gap-slot selection fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:GapSlotSelectionGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "gap-slot-selection.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "gap-slot-selection.spec",
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
    println("GAP_SLOT_SELECTION ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

function function_fence(source, helper)
    actual = observe(source, "x")
    println("GAP_SLOT_SELECTION_FENCE ", JSON3.write(actual))
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

function gap_source(definitions, action, item)
    return "$definitions\nList::\n @capture_gaps\n I {rows=[]}\n -> Item[word] {$action}\n LX {return(rows)}\nItem:\n word=/[^,;]+/\n I {$item}\n"
end

function context_failure(source)
    actual=observe(source,"x")
    println("GAP_SLOT_CONTEXT ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for route in ("native","restored","plan","fresh")
        row=actual[route]
        expected_class=route in ("native","restored") ? "RuntimeInterpreterException" : "GeneratedSourceException"
        @test get(row,"class","")==expected_class && occursin("gap_capture_context_unavailable",get(row,"error",""))
    end
    parsed=parse_spec_with_staged_user_function_definitions(source)
    failure=try
        runtime_execute(LinkedSpecRuntimeEngine(compile_spec(parsed)),"x")
        nothing
    catch error
        error
    end
    @test failure isa RuntimeInterpreterException
    @test failure.diagnostic.code=="gap_capture_context_unavailable"
    @test failure.diagnostic.stage=="access_gap_context"
    @test failure.diagnostic.helper_name=="gap_span"
end

@testset "Julia gap and slot record selection" begin
    @testset "Frozen shared gap slot target" begin
        root=dirname(dirname(@__DIR__))
        source=read(joinpath(root,"tests","fixtures","gap_slot_record_selection_values.spec"),String)
        expected=JSON3.read(read(joinpath(root,"tests","fixtures","gap_slot_record_selection_values.json"),String),Any)
        check(source,"a,b",expected)
    end
    @testset "Primitive full records and bound fields retain provenance" begin
        slot=Dict("target_rule"=>"Item","regex_index"=>0,"slot_id"=>"word","selector_kind"=>"named","authored_selector"=>"word")
        check(gap_source("","push(rows,[gap_span(),call(Item)])","return(entry_slot())"),"a,b",Any[
            Any[Dict("source_id"=>"input","start"=>0,"end"=>0,"provenance"=>"gap"),slot],
            Any[Dict("source_id"=>"input","start"=>1,"end"=>2,"provenance"=>"gap"),slot],
        ])
        check(gap_source("","span=gap_span();push(rows,[span[\"start\"].add(1),call(Item)])","entry_record=entry_slot();return(entry_record[\"slot_id\"].uppercase())"),"a,b",Any[Any[1,"WORD"],Any[2,"WORD"]])
    end
    @testset "Compatible direct fields preserve defined zero" begin
        check(gap_source("","push(rows,[gap_span()[\"end\"].coalesce(99).cat(\"!\"),call(Item)])","return([entry_slot()[\"regex_index\"].coalesce(99).add(1),entry_slot()[\"slot_id\"].uppercase()])"),"a,b",Any[Any["0!",Any[1,"WORD"]],Any["2!",Any[1,"WORD"]]])
    end
    @testset "Null direct slot recovers distinct kinds and signed Array reads" begin
        check(raw"""Top:: I {return([entry_slot(),entry_slot()["missing"].coalesce("M"),entry_slot()["missing"].coalesce(false),entry_slot()["missing"].coalesce(0),entry_slot()["missing"].coalesce(["a","tail"])[-1].uppercase()])}""","x",Any[nothing,"M",false,0,"TAIL"])
    end
    @testset "Unavailable gap errors precede field defaults" begin
        context_failure("Top:: I {return(gap_span())}")
        context_failure("Top:: I {return(gap_span()[\"start\"].coalesce(99))}")
    end
    @testset "Function state fence and explicit records remain distinct" begin
        for (helper,field) in (("gap_span","start"),("entry_slot","slot_id"))
            definitions="fn selected(){return($helper()[\"$field\"].coalesce(\"M\"))}"
            function_fence(gap_source(definitions,"push(rows,selected())","return(entry_text())"),helper)
        end
        source=gap_source("fn selected(span,item){return([span[\"start\"].add(1),item])}\nfn identify(slot){return(slot[\"slot_id\"].uppercase())}","push(rows,selected(gap_span(),call(Item)))","return(identify(entry_slot()))")
        check(source,"a,b",Any[Any[1,"WORD"],Any[2,"WORD"]])
    end
    @testset "Existing strict reader arity remains unchanged" begin
        for helper in ("entry_slot","gap_span","gap_text","gap_kind")
            for argument in ("1","extra:1")
                actual=observe("Top:: I {return($helper($argument))}","x")
                println("GAP_SLOT_ARITY ",JSON3.write(Dict("helper"=>helper,"argument"=>argument,"routes"=>actual)))
                @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
                for route in ("native","restored","plan","fresh")
                    row=actual[route]
                    expected_class=route in ("native","restored") ? "RuntimeInterpreterException" : "GeneratedSourceException"
                    @test get(row,"class","")==expected_class && all(occursin(part,get(row,"error","")) for part in ("helper_arity_mismatch",helper))
                end
            end
        end
    end
end
end
