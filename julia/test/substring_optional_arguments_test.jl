# TYPE-REFERENCE-BOOK.1.2.23.3.20.2: ordinary substring argument reference.
function check_substring_argument_consumers(source, expected)
    function same(actual)
        @test actual == expected
        if actual isa AbstractDict
            for field in ("null_effects", "defined_effects")
                @test actual[field][3] isa Number && !(actual[field][3] isa Bool)
            end
        end
    end
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    same(runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value)
    same(execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), "x", "substring-arguments.spec"))
    host = Module(gensym(:SubstringArgumentsGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "substring-arguments.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    same(Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end

@testset "Legacy substring free arities stay unchanged" begin
    check_substring_argument_consumers(raw"""Top:: I { return([substr("abc"),substr("abc",true,true,"extra"),substr("abc",1,undef,"extra")]); }""", Any[nothing,"b","bc"])
end

@testset "Substring optional argument reference" begin
    root = dirname(dirname(@__DIR__))
    source = read(joinpath(root,"tests","fixtures","substring_optional_argument_values.spec"),String)
    expected = JSON3.read(read(joinpath(root,"tests","fixtures","substring_optional_argument_values.json"),String),Any)
    check_substring_argument_consumers(source,expected)
end
