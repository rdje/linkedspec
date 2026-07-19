const CALLABLE_SIGNATURE_CONTRACT = JSON3.read(
    read(joinpath(REPO_ROOT, "capability_conformance", "callable_signature_contract.json"), String),
    Dict{String,Any},
)

function _compile_variadic_source(source::AbstractString)
    spec = parse_spec_with_staged_user_function_definitions(source)
    validate_spec(spec)
    return compile_spec(spec)
end

function _callable_fixture_source()
    return CALLABLE_SIGNATURE_CONTRACT["fixture"]["spec_source"]
end

@testset "Julia variadic user-function contract" begin
    @testset "definition shell emits exact v1 and v2 signature unions" begin
        nodes = parse_user_function_definition_asts(_callable_fixture_source())
        @test length(nodes) == 3

        fixed = nodes[1]
        @test fixed["version"] == 1
        @test fixed["params"] == Any["left", "right"]
        @test fixed["arity"] == 2
        @test !haskey(fixed, "signature")

        for (node, name, positional, minimum) in [
            (nodes[2], "all_values", Any[], 0),
            (nodes[3], "collect", Any["prefix"], 1),
        ]
            signature = node["signature"]
            @test node["version"] == 2
            @test node["name"] == name
            @test !haskey(node, "params")
            @test !haskey(node, "arity")
            @test signature == Dict{String,Any}(
                "kind" => "callable_signature",
                "version" => 1,
                "positional_params" => positional,
                "rest_param" => "items",
                "min_arity" => minimum,
                "max_arity" => nothing,
            )
            for staged_name in ("body_payload", "body_parse_job")
                staged = node[staged_name]
                @test staged["signature"] == signature
                @test !haskey(staged, "params")
                @test !haskey(staged, "arity")
            end
        end
    end

    @testset "descriptor and native runtime honor the neutral fixture" begin
        compiled = _compile_variadic_source(_callable_fixture_source())
        descriptor = to_descriptor_json(compiled)
        expected_keys = Set(String.(
            CALLABLE_SIGNATURE_CONTRACT["definition_versions"]["variadic"]["record_fields"],
        ))
        for name in ("all_values", "collect")
            record = descriptor["functions"][name]
            @test Set(keys(record)) == expected_keys
            @test record["version"] == 2
            @test !haskey(record, "params")
            @test !haskey(record, "arity")
        end

        result = runtime_execute(LinkedSpecRuntimeEngine(compiled), "xx")
        @test result.value == CALLABLE_SIGNATURE_CONTRACT["fixture"]["expected"]
    end

    @testset "arguments evaluate once left-to-right and rest arrays are fresh" begin
        compiled = _compile_variadic_source(raw"""fn gather(...items) { return(items) }
fn mutate_rest(...items) { items += "mutated"; return(items) }

Top::
 /x/ -> Done {
   order = "";
   first = gather(order = cat(order, "a"), order = cat(order, "b"), order);
   return({
     "first" : first,
     "fresh_one" : mutate_rest("a"),
     "fresh_two" : mutate_rest(),
     "order" : order
   })
 }

Done::
 /x/
""")
        @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "xx").value == Dict{String,Any}(
            "first" => Any["a", "ab", "ab"],
            "fresh_one" => Any["a", "mutated"],
            "fresh_two" => Any["mutated"],
            "order" => "ab",
        )
    end

    @testset "arity, malformed definitions, and keyword calls fail distinctly" begin
        fixed = replace(
            _callable_fixture_source(),
            "pair(\"left\", \"right\")" => "pair(\"left\", \"right\", \"extra\")";
            count = 1,
        )
        fixed_engine = LinkedSpecRuntimeEngine(_compile_variadic_source(fixed))
        @test_throws RuntimeInterpreterException runtime_execute(fixed_engine, "xx")
        try
            runtime_execute(fixed_engine, "xx")
        catch error
            @test occursin("user function 'pair' expects 2 argument(s), got 3", sprint(showerror, error))
        end

        variadic = replace(
            _callable_fixture_source(),
            "collect(\"p\")" => "collect()";
            count = 1,
        )
        variadic_engine = LinkedSpecRuntimeEngine(_compile_variadic_source(variadic))
        @test_throws RuntimeInterpreterException runtime_execute(variadic_engine, "xx")
        try
            runtime_execute(variadic_engine, "xx")
        catch error
            @test occursin("user function 'collect' expects at least 1 argument(s), got 0", sprint(showerror, error))
        end

        for params in ("...items, tail", "...left, ...right", "...", "items...", "... items")
            source = "fn bad($params) { return(undef) }\nTop::\n /x/\n"
            @test_throws Exception parse_spec_with_staged_user_function_definitions(source)
        end
        for params in ("item, ...item", "...return")
            source = "fn bad($params) { return(undef) }\nTop::\n /x/\n"
            @test_throws SpecValidationException validate_spec(
                parse_spec_with_staged_user_function_definitions(source),
            )
        end

        compiled = _compile_variadic_source(_callable_fixture_source())
        expression = ActionCallExpr(
            source = "collect(prefix = \"p\")",
            source_span = ActionSourceSpan(0, 21),
            name = "collect",
            args = [ActionKeywordArgument(
                name = "prefix",
                value = ActionStringLiteralExpr(
                    source = "\"p\"",
                    source_span = ActionSourceSpan(17, 20),
                    value = "p",
                    quote_char = "\"",
                ),
            )],
        )
        resolution = resolve_action_expression_contracts(
            expression;
            function_registry = compiled.function_registry,
        )
        @test only(resolution.diagnostics).code == "user_function_keyword_arguments_unsupported"
    end

    @testset "generated state preserves and executes variadic signatures" begin
        compiled = _compile_variadic_source(_callable_fixture_source())
        plan = build_generated_rule_plan(compiled)
        @test execute_generated_parser_v2(
            compiled,
            plan,
            "xx",
            "variadic-contract.spec",
        ) == CALLABLE_SIGNATURE_CONTRACT["fixture"]["expected"]

        generated = emit_julia_source_v2(compiled, "variadic-contract.spec")
        matched = match(r"const _COMPILED_SPEC_JSON_HEX = \"([^\"]+)\"", generated)
        @test matched !== nothing
        normalized = JSON3.read(String(hex2bytes(matched.captures[1])), Dict{String,Any})
        all_values = normalized["functions"][2]
        @test !haskey(all_values, "params")
        @test !haskey(all_values, "arity")
        @test all_values["signature"]["rest_param"] == "items"

        round_trip = compile_spec(from_json(SpecFile, normalized))
        @test runtime_execute(LinkedSpecRuntimeEngine(round_trip), "xx").value ==
              CALLABLE_SIGNATURE_CONTRACT["fixture"]["expected"]
    end
end
