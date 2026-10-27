# TYPE-REFERENCE-BOOK.1.2.23.3.31.6.3 — callback invocation identity controls.
function strict_callback_identity_equal(actual, expected)
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
            all(strict_callback_identity_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_callback_identity_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected callback identity fixture type $(typeof(expected))")
end
function callback_identity_routes(source, input)
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    host = Module(gensym(:CallbackIdentityGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "callback-identity.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    return (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "plan" => () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), input, "callback-identity.spec"),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
end
function check_callback_identity(source, input, expected)
    for (route, operation) in callback_identity_routes(source, input)
        value = try
            operation()
        catch failure
            println("CALLBACK_SUCCESS_ERROR ", route, " ", sprint(showerror, failure))
            @test false
            continue
        end
        println("CALLBACK_IDENTITY ", route, " ", JSON3.write(value))
        @test strict_callback_identity_equal(value, expected)
    end
end
callback_identity_top(body) = "Top:: I {$body}"
function reject_callback_identity(body, code, name, cycle)
    for (route, operation) in callback_identity_routes(callback_identity_top(body), "x")
        failure = try
            operation()
            nothing
        catch error
            error
        end
        @test failure !== nothing
        failure === nothing && continue
        text = sprint(showerror, failure)
        println("CALLBACK_ERROR ", route, " ", text)
        @test occursin(code, text)
        field = cycle === nothing ? "name" : "callable_name"
        @test occursin("$field=$(repr(name))", text)
        if cycle !== nothing
            @test occursin("cycle=$(repr(cycle))", text)
        end
        if failure isa RuntimeInterpreterException && failure.diagnostic isa RuntimeDiagnostic
            diagnostic = to_json(failure.diagnostic)
            @test diagnostic["code"] == code
            @test diagnostic["stage"] == "callable_codeblock_invocation"
            @test diagnostic[field] == name
            if cycle !== nothing
                @test diagnostic["cycle"] == cycle
                @test diagnostic["handler_source_label"] == "julia_runtime:codeblock:$name"
            end
        end
    end
end
@testset "Julia callback invocation identity" begin
    @testset "Distinct nested helper callbacks restore outer value" begin
        check_callback_identity(callback_identity_top(raw"""value="outer";result=with("outside"){return(with("inside"){return(value)})};return([result,value]);"""), "x", Any["inside","outer"])
    end
    @testset "Distinct explicit callbacks restore parameters" begin
        check_callback_identity(callback_identity_top(raw"""value="saved";result=with("outer",{|outer|return(with("inner",{|inner|return(cat(outer,inner))}))});return([result,value,coalesce(outer,"missing"),coalesce(inner,"missing")]);"""), "x", Any["outerinner","saved","missing","missing"])
    end
    @testset "Distinct nested tree callbacks" begin
        check_callback_identity(callback_identity_top(raw"""return([1].map_leaves(){return([value].map_leaves(){return(value)})})"""), "x", Any[Any[1]])
    end
    @testset "Helper bound cycle retains cb identity" begin
        reject_callback_identity(raw"""calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),with(v,cb),"escaped"))};return(cb("x"));""", "codeblock_recursion_unsupported", "cb", ["cb","cb"])
    end
    @testset "Receiver bound cycle retains cb identity" begin
        reject_callback_identity(raw"""calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),v.with(cb),"escaped"))};return(cb("x"));""", "codeblock_recursion_unsupported", "cb", ["cb","cb"])
    end
    @testset "Opaque helper callback retains cycle rejection" begin
        reject_callback_identity(raw"""calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),with(v,coalesce(cb,cb)),"escaped"))};return(cb("x"));""", "codeblock_recursion_unsupported", "cb", ["cb","cb"])
    end
    @testset "Anonymous body retains unknown helper diagnostic" begin
        reject_callback_identity(raw"""return(with("x"){return(missing())})""", "unknown_helper", "missing", nothing)
    end
    @testset "Direct and mutual cycle order" begin
        reject_callback_identity(raw"""calls=0;reader={||calls=num_add(calls,1);return(if(num_lt(calls,4),reader(),"escaped"))};return(reader());""", "codeblock_recursion_unsupported", "reader", ["reader","reader"])
        reject_callback_identity(raw"""calls=0;a={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),b(v),"escaped"))};b={|v|return(a(v))};return(a("x"));""", "codeblock_recursion_unsupported", "a", ["a","b","a"])
    end
    @testset "Caller callback named value resolves before scope" begin
        check_callback_identity(callback_identity_top(raw"""value={|item|return(cat(item,"!"))};return([with("a",value),"b".with(value),value("c")]);"""), "x", Any["a!","b!","c!"])
    end
    @testset "Named and anonymous failures restore all parameter stores" begin
        engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec("Top:: /x/")))
        for binding_name in ("cb", nothing)
            context = LinkedSpecJulia._RuntimeExecutionContext("x", "Top", nothing)
            record = LinkedSpecJulia._evaluate_runtime_action_expr!(
                engine,
                parse_action_expression(raw"""{|value|state="changed";value="inner";missing()}"""),
                context, "Top", nothing,
            )
            callback = LinkedSpecJulia._decode_runtime_codeblock(record)
            context.variables["value"] = Dict{String,Any}("scalar" => "outer")
            context.arrays["value"] = Any["outer-array"]
            context.hashes["value"] = Dict{String,Any}("key" => "outer-harray")
            failure = try
                LinkedSpecJulia._execute_runtime_codeblock_value!(
                    engine, binding_name === nothing ? "with" : binding_name,
                    callback, ActionExpr[], context, "Top", nothing;
                    evaluated_values = Any["argument"], binding_name = binding_name,
                )
                nothing
            catch error
                error
            end
            @test failure isa RuntimeInterpreterException
            if failure isa RuntimeInterpreterException
                @test failure.diagnostic isa RuntimeDiagnostic
                if failure.diagnostic isa RuntimeDiagnostic
                    @test failure.diagnostic.code == "unknown_helper"
                    @test failure.diagnostic.name == "missing"
                end
            end
            @test context.variables["value"] == Dict{String,Any}("scalar" => "outer")
            @test context.arrays["value"] == Any["outer-array"]
            @test context.hashes["value"] == Dict{String,Any}("key" => "outer-harray")
            @test context.variables["state"] == "changed"
            @test isempty(context.active_codeblocks)
        end
    end
end
