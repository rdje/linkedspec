# FUTURE-PARITY-BACKLOG.11.6.1-.3 — Julia callable-codeblock state/invocation/context.

const CALLABLE_CODEBLOCK_CONTRACT = JSON3.read(
    read(
        joinpath(REPO_ROOT, "capability_conformance", "callable_codeblock_contract.json"),
        String,
    ),
    Dict{String,Any},
)

const CALLABLE_CODEBLOCK_DESCRIPTOR_CONTRACT = JSON3.read(
    read(
        joinpath(REPO_ROOT, "capability_conformance", "outward_descriptor_contract.json"),
        String,
    ),
    Dict{String,Any},
)

function _callable_codeblock_assignment_value(source::AbstractString)
    block = parse_action_block("value = $source")
    assignment = only(block.statements).expr
    @test assignment isa ActionAssignScalarExpr
    return assignment.value
end

function _callable_codeblock_brace_kind(expression)
    if expression isa ActionHashLiteralExpr
        return "harray_literal"
    elseif expression isa ActionBlockValueExpr
        return "block_value"
    end
    return expression.kind
end

function _callable_codeblock_compile(source::AbstractString)
    spec = parse_spec_with_staged_user_function_definitions(source)
    validate_spec(spec)
    return compile_spec(spec)
end

function _callable_codeblock_attempt(call)
    try
        return call()
    catch error
        return error
    end
end

function _callable_codeblock_construction_source(literal::AbstractString)
    return """Top::
 /x/ -> Done {
   state = \"before\";
   cb = $literal;
   alias = copy(cb);
   return({ \"state\" : state, \"cb\" : alias })
 }

Done::
 /x/
"""
end

function _callable_codeblock_reconstruct(compiled::CompiledSpec, identity::AbstractString)
    generated = emit_julia_source_v2(compiled, identity)
    matched = match(r"const _COMPILED_SPEC_JSON_HEX = \"([^\"]+)\"", generated)
    @test matched !== nothing
    matched === nothing && return nothing
    normalized = JSON3.read(
        String(hex2bytes(matched.captures[1])),
        Dict{String,Any},
    )
    return compile_spec(from_json(SpecFile, normalized))
end

function _callable_codeblock_runtime_failure(compiled::CompiledSpec)
    error = _callable_codeblock_attempt() do
        runtime_execute(LinkedSpecRuntimeEngine(compiled), "x")
    end
    @test error isa RuntimeInterpreterException
    return error
end

function _callable_codeblock_invalid_call_source(id::AbstractString)
    body = if id == "fixed_missing"
        """cb = {|left, right| return(cat(left, right)) }; return(cb(\"a\"))"""
    elseif id == "fixed_extra"
        """cb = {|left, right| return(cat(left, right)) }; return(cb(\"a\", \"b\", \"c\"))"""
    elseif id == "rest_missing_fixed"
        """cb = {|prefix, ...items| return(items) }; return(cb())"""
    elseif id == "keyword_argument"
        """cb = {|value| return(value) }; return(cb(value: \"x\"))"""
    elseif id == "bound_non_codeblock"
        """text = \"not callable\"; return(text())"""
    elseif id == "unknown_call"
        """cb = {|| return(missing()) }; return(cb())"""
    elseif id == "direct_recursion"
        """reader = {|| return(reader()) }; return(reader())"""
    else
        error("unowned invalid callable-codeblock case $id")
    end
    return """Top::
 /x/
 E { $body }
"""
end

function _callable_codeblock_contextual_source()
    return """fn apply(value, callback: codeblock) { return(callback()) }
fn invoke(value, callback: codeblock) { return(callback(value)) }

Top::
 /x/
 E {
   return([
     with(\"x\") { return(cat(value, \"!\")) },
     with(\"x\", { return(cat(value, \"!\")) }),
     with(\"x\", {|item| return(cat(item, \"!\")) }),
     \"x\".with() { return(cat(value, \"!\")) },
     \"x\".with({ return(cat(value, \"!\")) }),
     \"x\".with({|item| return(cat(item, \"!\")) }),
     apply(\"a\") { return(cat(value, \"!\")) },
     apply(\"b\", { return(cat(value, \"?\")) }),
     invoke(\"c\", {|item| return(cat(item, \".\")) }),
     { \"b\" : 2, \"a\" : 1 }.map_leaves() { return(cat(value, \"!\")) },
     { \"b\" : 2, \"a\" : 1 }.map_leaves({ return(cat(value, \"!\")) }),
     [1, 2].map_leaves() { return(cat(value, \"!\")) },
     [1, 2].map_leaves({ return(cat(value, \"!\")) })
   ])
 }
"""
end

function _callable_codeblock_contextual_expected()
    return Any[
        "x!",
        "x!",
        "x!",
        "x!",
        "x!",
        "x!",
        "a!",
        "b?",
        "c.",
        Dict{String,Any}("a" => "1!", "b" => "2!"),
        Dict{String,Any}("a" => "1!", "b" => "2!"),
        Any["1!", "2!"],
        Any["1!", "2!"],
    ]
end

function _callable_codeblock_final_argument_json(expression::ActionExpr)
    encoded = to_json(expression)
    if expression isa ActionCallExpr
        return last(encoded["args"])
    elseif expression isa ActionFluentChainExpr
        return last(only(encoded["calls"])["args"])
    end
    error("expression $(expression.kind) has no callable final argument")
end

@testset "Julia callable-codeblock dynamic invocation contract" begin
    @testset "call-result access and colon keywords retain typed ActionIR" begin
        chain = parse_action_expression(
            """collector(\"p\", \"a\", \"b\")[\"items\"].length()""",
        )
        @test chain isa ActionFluentChainExpr
        if chain isa ActionFluentChainExpr
            @test chain.receiver isa ActionValueAccessExpr
            if chain.receiver isa ActionValueAccessExpr
                @test chain.receiver.receiver isa ActionCallExpr
                @test chain.receiver.receiver.name == "collector"
                @test length(chain.receiver.segments) == 1
                @test only(chain.receiver.segments) isa ActionKeyAccessSegment
                @test to_json(chain.receiver)["kind"] == "value_access"
            end
        end

        keyword = parse_action_expression("""cb(value: \"x\")""")
        @test keyword isa ActionCallExpr
        if keyword isa ActionCallExpr
            @test length(keyword.args) == 1
            @test only(keyword.args) isa ActionKeywordArgument
            if only(keyword.args) isa ActionKeywordArgument
                @test only(keyword.args).name == "value"
            end
        end

        assignment = parse_action_expression("""cb(value = \"x\")""")
        @test assignment isa ActionCallExpr
        if assignment isa ActionCallExpr
            @test length(assignment.args) == 1
            @test only(assignment.args) isa ActionPositionalArgument
            if only(assignment.args) isa ActionPositionalArgument
                @test only(assignment.args).value isa ActionAssignScalarExpr
            end
        end
    end

    @testset "exact neutral fixture executes through all in-memory authorities" begin
        fixture = CALLABLE_CODEBLOCK_CONTRACT["fixture"]
        expected = fixture["expected"]
        compiled = _callable_codeblock_compile(fixture["spec_source"])
        @test Set(row["id"] for row in CALLABLE_CODEBLOCK_CONTRACT["call_cases"]) == Set([
            "construction_is_deferred",
            "fixed_exact",
            "dynamic_read_uses_call_time_state",
            "nonparameter_mutation_persists",
            "parameter_binding_restores",
            "rest_empty",
            "rest_mixed",
            "rest_result_receiver_chain",
            "block_local_return",
            "standalone_discard_keeps_effects",
            "static_name_precedence",
        ])

        @test runtime_execute(
            LinkedSpecRuntimeEngine(compiled),
            fixture["input"],
        ).value == expected

        reconstructed = _callable_codeblock_reconstruct(
            compiled,
            "callable-codeblock-fixture.spec",
        )
        @test reconstructed isa CompiledSpec
        if reconstructed isa CompiledSpec
            @test runtime_execute(
                LinkedSpecRuntimeEngine(reconstructed),
                fixture["input"],
            ).value == expected
        end

        @test execute_generated_parser_v2(
            compiled,
            build_generated_rule_plan(compiled),
            fixture["input"],
            "callable-codeblock-fixture.spec",
        ) == expected

        generated = emit_julia_source_v2(
            compiled,
            "callable-codeblock-fixture.spec",
        )
        mktempdir() do scratch
            generated_path = joinpath(scratch, "callable_codeblock_fixture_generated.jl")
            write(generated_path, generated)
            host = Module(gensym(:JuliaCallableCodeblockInvocationHost))
            Base.include(host, generated_path)
            parser = Base.invokelatest(
                () -> getfield(host, :LinkedSpecGeneratedParser),
            )
            execute = Base.invokelatest(() -> getfield(parser, :execute))
            @test Base.invokelatest(execute, fixture["input"]) == expected
        end
    end

    @testset "remaining calls preserve precedence order copies and effects" begin
        compiled = _callable_codeblock_compile("""fn choose() { return(\"static\") }

Top::
 /x/
 E {
   state = \"\";
   append_state = {|value| state = cat(state, value); return(state) };
   append_state(\"x\");
   cat = {|left, right| return(\"shadow\") };
   choose = {|| return(\"shadow\") };
   order = \"\";
   tick = {|value| order = cat(order, value); return(value) };
   joiner = {|left, right| return(cat(left, right)) };
   original = { \"nested\" : [{ \"value\" : \"outer\" }] };
   mutate_copy = {|copy| copy[\"nested\"][0][\"value\"] = \"inner\"; return(copy) };
   mutated = mutate_copy(original);
   return({
     \"discard_state\" : state,
     \"helper_precedence\" : cat(\"a\", \"b\"),
     \"function_precedence\" : choose(),
     \"ordered_result\" : joiner(tick(\"a\"), tick(\"b\")),
     \"ordered_effect\" : order,
     \"original\" : original,
     \"mutated\" : mutated
   })
 }
""")
        @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value == Dict{String,Any}(
            "discard_state" => "x",
            "helper_precedence" => "ab",
            "function_precedence" => "static",
            "ordered_result" => "ab",
            "ordered_effect" => "ab",
            "original" => Dict{String,Any}(
                "nested" => Any[Dict{String,Any}("value" => "outer")],
            ),
            "mutated" => Dict{String,Any}(
                "nested" => Any[Dict{String,Any}("value" => "inner")],
            ),
        )
    end

    @testset "failure restores every parameter store and active identity" begin
        engine = LinkedSpecRuntimeEngine(
            _callable_codeblock_compile("""Top::
 /x/
"""),
        )
        context = LinkedSpecJulia._RuntimeExecutionContext("x", "Top", nothing)
        literal = parse_action_expression(
            """{|value| state = \"changed\"; value = \"inner\"; missing() }""",
        )
        context.variables["cb"] = LinkedSpecJulia._evaluate_runtime_action_expr!(
            engine,
            literal,
            context,
            "Top",
            nothing,
        )
        context.variables["value"] = Dict{String,Any}("scalar" => "outer")
        context.arrays["value"] = Any["outer-array"]
        context.hashes["value"] = Dict{String,Any}("key" => "outer-harray")
        expected_variable = deepcopy(context.variables["value"])
        expected_array = deepcopy(context.arrays["value"])
        expected_hash = deepcopy(context.hashes["value"])

        failure = _callable_codeblock_attempt() do
            LinkedSpecJulia._evaluate_runtime_action_expr!(
                engine,
                parse_action_expression("""cb(\"argument\")"""),
                context,
                "Top",
                nothing,
            )
        end
        @test failure isa RuntimeInterpreterException
        if failure isa RuntimeInterpreterException
            @test failure.diagnostic isa RuntimeDiagnostic
            if failure.diagnostic isa RuntimeDiagnostic
                @test failure.diagnostic.code == "unknown_helper"
                @test failure.diagnostic.name == "missing"
            end
        end
        @test context.variables["value"] == expected_variable
        @test context.arrays["value"] == expected_array
        @test context.hashes["value"] == expected_hash
        @test context.variables["state"] == "changed"
        @test isempty(context.active_codeblocks)
    end

    @testset "return raised below a helper remains invocation-local" begin
        compiled = _callable_codeblock_compile("""Top::
 /x/
 E {
   cb = {|| copy(return(\"done\")); return(\"wrong\") };
   result = cb();
   state = \"after\";
   return({ \"result\" : result, \"state\" : state })
 }
""")
        @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value ==
              Dict{String,Any}("result" => "done", "state" => "after")
    end

    @testset "all seven neutral call failures are typed across authorities" begin
        for row in CALLABLE_CODEBLOCK_CONTRACT["invalid_call_cases"]
            id = row["id"]
            expected = row["expected_error"]
            compiled = _callable_codeblock_compile(
                _callable_codeblock_invalid_call_source(id),
            )

            direct = _callable_codeblock_runtime_failure(compiled)
            if direct isa RuntimeInterpreterException
                @test direct.diagnostic isa RuntimeDiagnostic
                if direct.diagnostic isa RuntimeDiagnostic
                    diagnostic = to_json(direct.diagnostic)
                    for (key, value) in expected
                        @test get(diagnostic, key, nothing) == value
                    end
                end
            end

            reconstructed = _callable_codeblock_reconstruct(
                compiled,
                "callable-codeblock-$id.spec",
            )
            @test reconstructed isa CompiledSpec
            if reconstructed isa CompiledSpec
                round_trip = _callable_codeblock_runtime_failure(reconstructed)
                if direct isa RuntimeInterpreterException &&
                        direct.diagnostic isa RuntimeDiagnostic &&
                        round_trip isa RuntimeInterpreterException &&
                        round_trip.diagnostic isa RuntimeDiagnostic
                    @test to_json(round_trip.diagnostic) == to_json(direct.diagnostic)
                end
            end

            generated = _callable_codeblock_attempt() do
                execute_generated_parser_v2(
                    compiled,
                    build_generated_rule_plan(compiled),
                    "x",
                    "callable-codeblock-$id.spec",
                )
            end
            @test generated isa GeneratedSourceException
            if generated isa GeneratedSourceException
                @test occursin(expected["code"], something(generated.detail, ""))
            end

            emitted_source = emit_julia_source_v2(
                compiled,
                "callable-codeblock-$id-emitted.spec",
            )
            mktempdir() do scratch
                generated_path = joinpath(scratch, "callable_codeblock_$id.jl")
                write(generated_path, emitted_source)
                host = Module(gensym(:JuliaCallableCodeblockFailureHost))
                Base.include(host, generated_path)
                parser = Base.invokelatest(
                    () -> getfield(host, :LinkedSpecGeneratedParser),
                )
                execute = Base.invokelatest(() -> getfield(parser, :execute))
                emitted = _callable_codeblock_attempt() do
                    Base.invokelatest(execute, "x")
                end
                @test emitted isa GeneratedSourceException
                if emitted isa GeneratedSourceException
                    @test occursin(expected["code"], something(emitted.detail, ""))
                end
            end
        end
    end

    @testset "mutual recursion retains the exact ordered cycle" begin
        compiled = _callable_codeblock_compile("""Top::
 /x/
 E {
   left = {|| return(right()) };
   right = {|| return(left()) };
   return(left())
 }
""")
        failure = _callable_codeblock_runtime_failure(compiled)
        if failure isa RuntimeInterpreterException && failure.diagnostic isa RuntimeDiagnostic
            diagnostic = to_json(failure.diagnostic)
            @test diagnostic["code"] == "codeblock_recursion_unsupported"
            @test diagnostic["callable_name"] == "left"
            @test diagnostic["cycle"] == ["left", "right", "left"]
        end
    end
end

@testset "Julia generic final-codeblock normalization contract" begin
    @testset "typed declaration and all neutral contextual AST cases are metadata-owned" begin
        contextual = CALLABLE_CODEBLOCK_CONTRACT["contextual_final_block_cases"]
        @test Set(row["id"] for row in contextual) == Set([
            "helper_attached",
            "helper_parenthesized",
            "user_function_attached",
            "user_function_parenthesized",
            "receiver_attached",
            "receiver_parenthesized",
            "explicit_literal",
            "harray_not_promoted",
        ])

        source = _callable_codeblock_contextual_source()
        parsed = parse_spec_with_staged_user_function_definitions(source)
        apply = only(definition for definition in parsed.functions if definition.name == "apply")
        @test apply.params == ["value", "callback"]
        @test apply.arity == 2
        @test apply.parameter_kinds == Dict("callback" => "codeblock")
        @test apply.body_payload["fixed_params"] == Any["value"]
        @test apply.body_payload["codeblock_param"] == "callback"
        @test apply.body_payload["parameter_kinds"] == Dict("callback" => "codeblock")
        @test apply.body_parse_job.fixed_params == ["value"]
        @test apply.body_parse_job.codeblock_param == "callback"
        @test apply.body_parse_job.parameter_kinds == Dict("callback" => "codeblock")

        compiled = compile_spec(parsed)
        descriptor = to_descriptor_json(compiled)["functions"]["apply"]
        variant = CALLABLE_CODEBLOCK_DESCRIPTOR_CONTRACT["function_record_variants"]["final_codeblock_v3"]
        @test Set(keys(descriptor)) == Set{String}(variant["record_fields"])
        @test descriptor["version"] == 3
        @test descriptor["params"] == ["value", "callback"]
        @test descriptor["arity"] == 2
        @test descriptor["parameter_kinds"] == Dict("callback" => "codeblock")

        payload = only(compiled.rules_by_label["Top"].lifecycle_action_payloads)
        returned = only(payload.action_ast.statements).expr
        @test returned isa ActionCallExpr
        items = only(returned.args).value.items
        for (attached_index, parenthesized_index) in (
            (1, 2),
            (4, 5),
            (10, 11),
            (12, 13),
        )
            attached = _callable_codeblock_final_argument_json(items[attached_index])
            parenthesized = _callable_codeblock_final_argument_json(items[parenthesized_index])
            for field in ("kind", "version", "signature", "body_source")
                @test attached[field] == parenthesized[field]
            end
            @test attached["body_ast"]["source"] == parenthesized["body_ast"]["source"]
            @test [row["source"] for row in attached["body_ast"]["statements"]] ==
                  [row["source"] for row in parenthesized["body_ast"]["statements"]]
            @test attached["kind"] == "codeblock_argument"
            @test attached["signature"]["positional_params"] == Any[]
            @test attached["signature"]["max_arity"] == 0
        end
        for explicit_index in (3, 6, 9)
            @test _callable_codeblock_final_argument_json(items[explicit_index])["kind"] ==
                  "codeblock_literal"
        end
        @test !occursin("contextual_codeblock_candidate", JSON3.write(to_json(compiled)))

        index = semantic_index(
            source;
            logical_name = "callable-codeblock-final-equivalence.spec",
            source_detail_ceiling = SemanticSourceNoneDetail,
        )
        projection = LinkedSpecJulia._semantic_static_projection_for_testing(index)
        function_record = only(
            record for record in projection["records"] if
            record["kind"] == "function" && record["name"] == "apply"
        )
        @test function_record["facts"]["parameter_kinds"] == Any["value", "codeblock"]
        @test function_record["facts"]["signature"]["final_codeblock"] == true
    end

    @testset "contextual forms execute through every Julia authority" begin
        source = _callable_codeblock_contextual_source()
        expected = _callable_codeblock_contextual_expected()
        compiled = _callable_codeblock_compile(source)
        @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value == expected

        reconstructed = _callable_codeblock_reconstruct(
            compiled,
            "callable-codeblock-final-equivalence.spec",
        )
        @test reconstructed isa CompiledSpec
        if reconstructed isa CompiledSpec
            @test runtime_execute(LinkedSpecRuntimeEngine(reconstructed), "x").value == expected
        end
        @test execute_generated_parser_v2(
            compiled,
            build_generated_rule_plan(compiled),
            "x",
            "callable-codeblock-final-equivalence.spec",
        ) == expected

        generated = emit_julia_source_v2(
            compiled,
            "callable-codeblock-final-equivalence.spec",
        )
        mktempdir() do scratch
            generated_path = joinpath(scratch, "callable_codeblock_contextual_generated.jl")
            write(generated_path, generated)
            host = Module(gensym(:JuliaContextualCodeblockHost))
            Base.include(host, generated_path)
            parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
            execute = Base.invokelatest(() -> getfield(parser, :execute))
            @test Base.invokelatest(execute, "x") == expected
        end
    end

    @testset "eager blocks controls and callback resolution remain distinct" begin
        compiled = _callable_codeblock_compile("""Top::
 /x/
 E {
   state = "before";
   eager = array({ state = "eager"; state });
   if(true) { state = cat(state, "!") };
   return([state, eager])
 }
""")
        encoded = JSON3.write(to_json(compiled))
        @test occursin("block_value", encoded)
        @test occursin("control_if", encoded)
        @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value ==
              Any["eager!", Any["eager"]]

        unknown = _callable_codeblock_attempt() do
            _callable_codeblock_compile("""Top::
 /x/
 E { return(custom("x") { return(value) }) }
""")
        end
        @test unknown isa CompiledSpecException
        @test occursin("callable_contract_rejected", sprint(showerror, unknown))

        unknown_receiver = _callable_codeblock_attempt() do
            _callable_codeblock_compile("""Top::
 /x/
 E { return("x".custom() { return(value) }) }
""")
        end
        @test unknown_receiver isa CompiledSpecException
        @test occursin("callable_contract_rejected", sprint(showerror, unknown_receiver))
        @test occursin("receiver", sprint(showerror, unknown_receiver))

        resolution = _callable_codeblock_compile("""Top::
 /x/
 E {
   value = {|item| return(cat(item, "!")) };
   return([with("a", value), "b".with(value)])
 }
""")
        @test runtime_execute(LinkedSpecRuntimeEngine(resolution), "x").value == Any["a!", "b!"]
    end

    @testset "typed metadata arity declarations and final values fail closed" begin
        parsed = parse_spec_with_staged_user_function_definitions(
            """fn apply(value, callback: codeblock) { return(callback()) }

Top::
 /x/
""",
        )
        malformed = JSON3.read(JSON3.write(to_json(parsed)), Dict{String,Any})
        only(malformed["functions"])["body_parse_job"]["parameter_kinds"] =
            Dict("value" => "codeblock")
        drift = _callable_codeblock_attempt() do
            stitch_function_body_parse_jobs(from_json(SpecFile, malformed))
        end
        @test drift isa StagedParserRegistryException
        @test occursin("final-codeblock metadata does not match", sprint(showerror, drift))

        malformed_payload = JSON3.read(JSON3.write(to_json(parsed)), Dict{String,Any})
        only(malformed_payload["functions"])["body_payload"]["parameter_kinds"] =
            Dict("value" => "codeblock")
        payload_drift = _callable_codeblock_attempt() do
            stitch_function_body_parse_jobs(from_json(SpecFile, malformed_payload))
        end
        @test payload_drift isa StagedParserRegistryException
        @test occursin("body_payload final-codeblock metadata", sprint(showerror, payload_drift))

        malformed_definition = JSON3.read(JSON3.write(to_json(parsed)), Dict{String,Any})
        only(malformed_definition["functions"])["parameter_kinds"] =
            Dict("value" => "codeblock")
        definition_drift = _callable_codeblock_attempt() do
            validate_spec(from_json(SpecFile, malformed_definition))
        end
        @test definition_drift isa SpecValidationException
        @test occursin("invalid final-codeblock parameter kinds", sprint(showerror, definition_drift))

        for (surface, expression) in (
            ("helper", "with(\"a\", \"b\") { return(value) }"),
            ("receiver", "\"a\".with(\"b\") { return(value) }"),
            ("user_function", "apply(\"a\", \"b\") { return(value) }"),
        )
            failure = _callable_codeblock_attempt() do
                _callable_codeblock_compile("""fn apply(value, callback: codeblock) { return(callback()) }

Top::
 /x/
 E { return($expression) }
""")
            end
            @test failure isa CompiledSpecException
            @test occursin("callable_contract_arity_mismatch", sprint(showerror, failure))
        end

        declaration = CALLABLE_CODEBLOCK_CONTRACT["final_codeblock_parameter_declaration"]
        for row in declaration["invalid"]
            failure = _callable_codeblock_attempt() do
                parse_spec_with_staged_user_function_definitions("""fn invalid($(row["source"])) { return(undef) }

Top::
 /x/
""")
            end
            @test occursin(row["expected_code"], sprint(showerror, failure))
        end

        for (name, expression) in (
            ("typed_function", "apply(\"x\", { \"value\" : value })"),
            ("helper", "with(\"x\", { \"value\" : value })"),
            ("receiver", "\"x\".with({ \"value\" : value })"),
        )
            compiled = _callable_codeblock_compile(
                """fn apply(value, callback: codeblock) { return(callback()) }

Top::
 /x/
 E { return($expression) }
""",
            )
            failure = _callable_codeblock_runtime_failure(compiled)
            @test failure.diagnostic.code == "final_argument_not_codeblock"
            @test failure.diagnostic.value_kind == "harray"

            reconstructed = _callable_codeblock_reconstruct(
                compiled,
                "callable-codeblock-final-$name.spec",
            )
            @test reconstructed isa CompiledSpec
            if reconstructed isa CompiledSpec
                round_trip = _callable_codeblock_runtime_failure(reconstructed)
                @test to_json(round_trip.diagnostic) == to_json(failure.diagnostic)
            end
            generated = _callable_codeblock_attempt() do
                execute_generated_parser_v2(
                    compiled,
                    build_generated_rule_plan(compiled),
                    "x",
                    "callable-codeblock-final-$name.spec",
                )
            end
            @test generated isa GeneratedSourceException
            @test occursin(
                "final_argument_not_codeblock",
                something(generated.detail, ""),
            )
        end

        emitted_invalid = _callable_codeblock_compile(
            """fn apply(value, callback: codeblock) { return(callback()) }

Top::
 /x/
 E { return(apply("x", { "value" : value })) }
""",
        )
        generated = emit_julia_source_v2(
            emitted_invalid,
            "callable-codeblock-final-invalid-emitted.spec",
        )
        mktempdir() do scratch
            generated_path = joinpath(scratch, "callable_codeblock_contextual_invalid.jl")
            write(generated_path, generated)
            host = Module(gensym(:JuliaContextualCodeblockInvalidHost))
            Base.include(host, generated_path)
            parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
            execute = Base.invokelatest(() -> getfield(parser, :execute))
            failure = _callable_codeblock_attempt() do
                Base.invokelatest(execute, "x")
            end
            @test failure isa GeneratedSourceException
            @test occursin(
                "final_argument_not_codeblock",
                something(failure.detail, ""),
            )
        end
    end
end

@testset "Julia callable-codeblock construction contract" begin
    @testset "neutral brace classes and literal records are exact" begin
        for row in CALLABLE_CODEBLOCK_CONTRACT["brace_classification"]
            expression = _callable_codeblock_assignment_value(row["source"])
            @test _callable_codeblock_brace_kind(expression) == row["expected_kind"]
        end

        expected_fields = Set{String}(CALLABLE_CODEBLOCK_CONTRACT["ast_schema"]["fields"])
        for row in CALLABLE_CODEBLOCK_CONTRACT["literals"]
            source = row["source"]
            prefix = "value = "
            expression = _callable_codeblock_assignment_value(source)
            @test expression isa ActionCodeblockLiteralExpr
            record = to_json(expression)
            @test Set{String}(keys(record)) == expected_fields
            @test get(record, "kind", nothing) == "codeblock_literal"
            @test get(record, "version", nothing) == 1
            @test get(record, "source_text", nothing) == source
            @test get(record, "body_source", nothing) == row["body_source"]
            body = get(record, "body_ast", nothing)
            @test body isa AbstractDict
            if body isa AbstractDict
                @test body["kind"] == "action_block"
                @test body["source"] == row["body_source"]
                @test !isempty(body["statements"])
            end
            source_span = get(record, "source_span", Dict{String,Any}())
            @test get(source_span, "start", nothing) == length(prefix)
            @test get(source_span, "end", nothing) == length(prefix * source)

            body_start = findnext('|', source, 3)
            @test body_start !== nothing
            if body_start !== nothing
                body_span = get(record, "body_span", Dict{String,Any}())
                @test get(body_span, "start", nothing) ==
                      length(prefix * first(source, body_start))
                @test get(body_span, "end", nothing) ==
                      length(prefix * chop(source; tail = 1))
            end

            signature = get(record, "signature", Dict{String,Any}())
            signature_source = row["signature_source"]
            parts = isempty(signature_source) ? String[] :
                    [strip(part) for part in split(signature_source, ',')]
            rest = [part[4:end] for part in parts if startswith(part, "...")]
            positional = [part for part in parts if !startswith(part, "...")]
            @test get(signature, "kind", nothing) == "callable_signature"
            @test get(signature, "version", nothing) == 1
            @test get(signature, "positional_params", nothing) == positional
            @test get(signature, "rest_param", nothing) ==
                  (isempty(rest) ? nothing : only(rest))
            @test get(signature, "min_arity", nothing) == length(positional)
            @test get(signature, "max_arity", nothing) ==
                  (isempty(rest) ? length(positional) : nothing)
        end

        nested_source =
            "{|value| return({ \"marker\" : \"|}\", \"nested\" : { \"value\" : value } }) }"
        nested = parse_action_expression(nested_source)
        @test nested isa ActionCodeblockLiteralExpr
        @test nested.source == nested_source
        @test only(nested.body_ast.statements).expr isa ActionCallExpr
    end

    @testset "literal spans use containing Unicode-character coordinates" begin
        source = "note = \"😀\"; cb = {|value| return(value) }"
        block = parse_action_block(source)
        assignment = block.statements[2].expr
        @test assignment isa ActionAssignScalarExpr
        record = to_json(assignment.value)
        literal_start = findfirst("{|", source)
        @test literal_start !== nothing
        if literal_start !== nothing
            prefix_end = prevind(source, first(literal_start))
            expected_start = length(source[firstindex(source):prefix_end])
            @test get(record, "source_span", Dict())["start"] == expected_start
            @test get(record, "source_span", Dict())["end"] == length(source)
        end

        nested_source = "prefix = \"😀\"; cb = {|| nested = {|value| return(value) } }"
        nested_block = parse_action_block(nested_source)
        outer = to_json(nested_block.statements[2].expr.value)
        inner = _callable_codeblock_attempt() do
            outer["body_ast"]["statements"][1]["expr"]["value"]
        end
        @test inner isa AbstractDict
        if inner isa AbstractDict
            inner_start = findlast("{|", nested_source)
            @test inner_start !== nothing
            if inner_start !== nothing
                prefix_end = prevind(nested_source, first(inner_start))
                @test inner["source_span"]["start"] ==
                      length(nested_source[firstindex(nested_source):prefix_end])
            end
        end
    end

    @testset "all malformed literals retain neutral diagnostic codes" begin
        for row in CALLABLE_CODEBLOCK_CONTRACT["invalid_literal_cases"]
            expression = parse_action_expression(row["source"])
            @test expression isa ActionCodeblockLiteralErrorExpr
            record = to_json(expression)
            @test get(record, "code", nothing) == row["expected_code"]
            resolution = resolve_action_expression_contracts(expression)
            @test length(resolution.diagnostics) == 1
            if length(resolution.diagnostics) == 1
                @test only(resolution.diagnostics).code == row["expected_code"]
            end
        end
    end

    @testset "construction compiled state and generated plan remain inert" begin
        literal = only(
            row for row in CALLABLE_CODEBLOCK_CONTRACT["literals"] if
            row["id"] == "mutate_dynamic"
        )
        source = _callable_codeblock_construction_source(literal["source"])
        compiled = _callable_codeblock_attempt(() -> _callable_codeblock_compile(source))
        @test compiled isa CompiledSpec
        if compiled isa CompiledSpec
            direct = runtime_execute(LinkedSpecRuntimeEngine(compiled), "xx").value
            @test direct["state"] == "before"
            @test direct["cb"]["kind"] == "codeblock_literal"
            @test direct["cb"]["source_text"] == literal["source"]
            @test direct["cb"]["body_source"] == literal["body_source"]
            @test direct["cb"]["signature"]["positional_params"] == Any["value"]
            @test occursin("codeblock_literal", JSON3.write(to_json(compiled)))
            @test execute_generated_parser_v2(
                compiled,
                build_generated_rule_plan(compiled),
                "xx",
                "callable-codeblock-construction.spec",
            ) == direct

            generated = emit_julia_source_v2(
                compiled,
                "callable-codeblock-construction.spec",
            )
            matched = match(r"const _COMPILED_SPEC_JSON_HEX = \"([^\"]+)\"", generated)
            @test matched !== nothing
            if matched !== nothing
                normalized = JSON3.read(
                    String(hex2bytes(matched.captures[1])),
                    Dict{String,Any},
                )
                reconstructed = compile_spec(from_json(SpecFile, normalized))
                @test runtime_execute(
                    LinkedSpecRuntimeEngine(reconstructed),
                    "xx",
                ).value == direct

                mktempdir() do scratch
                    generated_path = joinpath(scratch, "callable_codeblock_generated.jl")
                    write(generated_path, generated)
                    host = Module(gensym(:JuliaCallableCodeblockConstructionHost))
                    Base.include(host, generated_path)
                    parser = Base.invokelatest(
                        () -> getfield(host, :LinkedSpecGeneratedParser),
                    )
                    execute = Base.invokelatest(() -> getfield(parser, :execute))
                    @test Base.invokelatest(execute, "xx") == direct
                end
            end
        end
    end

    @testset "user functions transport literals and nullable signatures stay isolated" begin
        source = """fn identity(value) { return(value) }
fn make() { return({|| return(\"never\") }) }

Top::
 /x/ -> Done {
   state = \"before\";
   from_arg = identity({|value| state = \"wrong\"; return(value) });
   from_result = make();
   return({
     \"state\" : state,
     \"from_arg\" : from_arg,
     \"from_result\" : from_result
   })
 }

Done::
 /x/
"""
        result = runtime_execute(
            LinkedSpecRuntimeEngine(_callable_codeblock_compile(source)),
            "xx",
        ).value
        @test result["state"] == "before"
        @test result["from_arg"]["kind"] == "codeblock_literal"
        @test result["from_result"]["kind"] == "codeblock_literal"
        @test result["from_arg"]["signature"]["positional_params"] == Any["value"]
        @test result["from_result"]["signature"]["max_arity"] == 0

        variadic = parse_spec_with_staged_user_function_definitions(
            """fn gather(...items) { return(items) }

Top::
 /x/
""",
        )
        normalized = JSON3.read(JSON3.write(to_json(variadic)), Dict{String,Any})
        only(normalized["functions"])["signature"]["rest_param"] = nothing
        reconstructed = from_json(SpecFile, normalized)
        error = _callable_codeblock_attempt(() -> validate_spec(reconstructed))
        @test error isa SpecValidationException
        @test occursin("invalid rest parameter", sprint(showerror, error))
    end

    @testset "deferred bodies and semantic signatures remain typed" begin
        literal = parse_action_expression(
            "{|| state = \"wrong\"; missing(); call(Done); return(retv) }",
        )
        @test literal.kind == "codeblock_literal"
        @test isempty(resolve_action_expression_contracts(literal).diagnostics)
        @test only(resolve_action_expression_contracts(parse_action_expression("cb()")).diagnostics).code ==
              "unknown_helper"

        source = """fn identity(value) { return(value) }

Top::
 /x/ -> Done {
   cb = {|left, ...items| return(items) };
   return(cb)
 }

Done::
 /x/
"""
        index = _callable_codeblock_attempt() do
            semantic_index(
                source;
                logical_name = "callable-codeblock-semantic.spec",
                source_detail_ceiling = SemanticSourceNoneDetail,
            )
        end
        @test index isa SemanticIndex
        if index isa SemanticIndex
            projection = LinkedSpecJulia._semantic_static_projection_for_testing(index)
            bindings = [
                record for record in projection["records"] if
                record["kind"] == "binding" && record["name"] == "cb"
            ]
            @test length(bindings) == 1
            if length(bindings) == 1
                shape = only(bindings)["facts"]["value_shape"]
                @test shape["kind"] == "codeblock"
                @test shape["signature"] == Dict{String,Any}(
                    "parameters" => Any[
                        Dict{String,Any}(
                            "name" => "left",
                            "kind" => "value",
                            "required" => true,
                        ),
                    ],
                    "arity_min" => 1,
                    "arity_max" => nothing,
                    "rest_parameter" => "items",
                    "final_codeblock" => false,
                )
            end
        end
    end
end
