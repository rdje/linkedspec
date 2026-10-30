module JuliaGapStringResult
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
    error("unexpected cursor rewind fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:GapStringGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "gap-string-result.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "gap-string-result.spec",
        ),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
        result[route] = try
            Dict("ok" => operation())
        catch failure
            row=Dict{String,Any}("error"=>sprint(showerror, failure), "class"=>string(nameof(typeof(failure))))
            if failure isa RuntimeInterpreterException && failure.diagnostic !== nothing
                diagnostic=failure.diagnostic
                row["diagnostic"]=Dict("code"=>diagnostic.code,"stage"=>diagnostic.stage,
                    "helper_name"=>diagnostic.helper_name,"actual_arity"=>diagnostic.actual_arity,
                    "expected_arity"=>diagnostic.expected_arity)
            end
            row
        end
    end
    return result
end

function check(label, source, input, expected)
    actual = observe(source, input)
    println("GAP_STRING_RESULT ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

function function_fence(source, helper, label=helper)
    actual = observe(source, "a,b;")
    println("GAP_STRING_FUNCTION ", label, " ", JSON3.write(actual))
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



function carrier(action, definitions="", pattern="[^,;]+")
    return "$definitions\nList::\n @capture_gaps\n I {rows=[];order=\"\"}\n -> Item[word] {$action}\n LX {return([rows,gap_text(),gap_kind(),order,cursor_pos()])}\nItem:\n word=/$pattern/\n I {return(entry_text())}\n"
end
function error_case(label,source,helper,code,stage)
    actual=observe(source,"x")
    println("GAP_STRING_ERROR ",label," ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for (route,row) in actual
        expected_class=route in ("native","restored") ? "RuntimeInterpreterException" : "GeneratedSourceException"
        valid=get(row,"class","")==expected_class && occursin(code,get(row,"error",""))
        if route in ("native","restored")
            d=get(row,"diagnostic",Dict())
            valid=valid && get(d,"code",nothing)==code && get(d,"stage",nothing)==stage && get(d,"helper_name",nothing)==helper
            if code=="helper_arity_mismatch"
                valid=valid && get(d,"actual_arity",nothing)==1 && get(d,"expected_arity",nothing)=="exactly 0 arguments"
            end
        end
        @test valid
    end
end
@testset "Julia gap String result guards" begin
    @testset "Frozen shared target" begin
        root=dirname(dirname(@__DIR__))
        source=read(joinpath(root,"tests","fixtures","gap_string_result_values.spec"),String)
        expected=JSON3.read(read(joinpath(root,"tests","fixtures","gap_string_result_values.json"),String),Any)
        check("shared",source,"a,b;",expected)
    end
    @testset "Primitive and bound direct compatible Strings" begin
        check("primitive",carrier("push(rows,[gap_text(),gap_kind(),call(Item)])"),"a,b;",Any[Any[Any["","prefix","a"],Any[",","interstitial","b"]],";","tail","",3])
        check("compatible",carrier(raw"""text=gap_text();kind=gap_kind();push(rows,[text.coalesce("F").cat("!"),gap_text().coalesce("F").cat("!"),kind.uppercase(),gap_kind().uppercase(),call(Item)])"""),"a,b;",Any[Any[Any["!","!","PREFIX","PREFIX","a"],Any[",!",",!","INTERSTITIAL","INTERSTITIAL","b"]],";","tail","",3])
    end
    @testset "Incompatible consumers null and skip operands" begin
        check("guards",carrier(raw"""a=gap_text().take({order=cat(order,"A");1});b=gap_kind().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});push(rows,[a,b,call(Item)])"""),"a,b;",Any[Any[Any[nothing,nothing,"a"],Any[nothing,nothing,"b"]],";","tail","",3])
    end
    @testset "Noncontainer recovery preserves Array Bool Number String" begin
        check("recovery",carrier(raw"""push(rows,[gap_text()[0].coalesce(["a","tail"])[-1].uppercase(),gap_kind()["missing"].coalesce(false),gap_kind()[0].coalesce(0).add(1),gap_text()[0].coalesce("").cat("!"),call(Item)])"""),"a,b;",Any[Any[Any["TAIL",false,1,"!","a"],Any["TAIL",false,1,"!","b"]],";","tail","",3])
    end
    @testset "With kinds and outer value restoration" begin
        check("with_kinds",carrier(raw"""value="outer";a=gap_text().with(){return([value,"tail"])}[-1].uppercase();b=gap_kind().with(){return({"k":[false]})}["k"][-1];push(rows,[a,b,value,call(Item)])"""),"a,b;",Any[Any[Any["TAIL",false,"outer","a"],Any["TAIL",false,"outer","b"]],";","tail","",3])
    end
    @testset "Unicode gap text character length" begin
        check("unicode",carrier(raw"""push(rows,[gap_text().length(),gap_text().cat("!"),call(Item)])""","","[ab]"),"a🙂b;",Any[Any[Any[0,"!","a"],Any[1,"🙂!","b"]],";","tail","",3])
    end
    @testset "Unavailable context precedes defaults" begin
        for helper in ("gap_text","gap_kind"), suffix in ("",".coalesce(\"M\")")
            error_case(helper*suffix,"Top:: I {return($(helper)()$(suffix))}",helper,"gap_capture_context_unavailable","access_gap_context")
        end
    end
    @testset "Pure function primitive computed reads remain forbidden" begin
        for helper in ("gap_text","gap_kind"), suffix in ("","[0]")
            definitions="fn denied(){return($(helper)()$(suffix).coalesce(\"M\"))}"
            function_fence(carrier("push(rows,[denied(),call(Item)])",definitions),helper,helper*(isempty(suffix) ? "_primitive" : "_read"))
        end
        check("explicit_args",carrier("push(rows,[selected(gap_text(),gap_kind()),call(Item)])",raw"""fn selected(text,kind){return([text.cat("!"),kind.uppercase()])}"""),"a,b;",Any[Any[Any[Any["!","PREFIX"],"a"],Any[Any[",!","INTERSTITIAL"],"b"]],";","tail","",3])
    end
    @testset "Malformed counts retain original arity before context" begin
        for helper in ("gap_text","gap_kind"), argument in ("1","extra:1")
            source="Top:: I {return($(helper)($(argument))[0].coalesce(\"M\"))}"
            error_case(helper*"_"*argument,source,helper,"helper_arity_mismatch","helper_arity_mismatch")
        end
    end
end
end
