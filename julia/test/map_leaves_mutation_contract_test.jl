# FUTURE-PARITY-BACKLOG.19.5.2 — Julia `map_leaves!` mutation contract.

const JULIA_MAP_LEAVES_MUTATION_CONTRACT = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "map_leaves_mutation_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)

const JULIA_WRITE_MAP_LEAVES_COMPOSITION_CONTRACT = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "write_map_leaves_composition_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)

function _map_leaves_mutation_source(action::AbstractString)
    return """
Top::
 -> Done { $action }

Done::
 /[a-z]+/
"""
end

function _map_leaves_mutation_engine(action::AbstractString)
    return _map_leaves_mutation_source_engine(_map_leaves_mutation_source(action))
end

function _map_leaves_mutation_source_engine(source::AbstractString)
    return LinkedSpecRuntimeEngine(
        compile_spec(parse_spec_with_staged_user_function_definitions(source)),
    )
end

function _map_leaves_mutation_failure(
    action::AbstractString;
    diagnostic_output_sink = nothing,
)
    failure = try
        runtime_parse(
            _map_leaves_mutation_engine(action),
            "xhello";
            diagnostic_output_sink,
        )
        nothing
    catch error
        error
    end
    @test failure isa RuntimeInterpreterException
    return failure
end

function _map_leaves_mutation_scalar_slice(source::AbstractString, start::Int, stop::Int)
    chars = collect(String(source))
    return String(chars[(start + 1):stop])
end

function _map_leaves_mutation_private_context(
    initial_bindings;
    diagnostic_output_sink = nothing,
)
    context = LinkedSpecJulia._RuntimeExecutionContext(
        "xhello",
        "Top",
        nothing;
        diagnostic_output_sink,
    )
    for (name, value) in pairs(initial_bindings)
        LinkedSpecJulia._store_runtime_bare_binding!(
            context,
            String(name),
            deepcopy(value),
        )
    end
    return context
end

function _map_leaves_mutation_private_value(context, name::String)
    _, value = LinkedSpecJulia._runtime_store_for_write(context, name)
    return deepcopy(value)
end

function _map_leaves_mutation_private_evaluate(engine, context, source::String)
    return LinkedSpecJulia._evaluate_runtime_action_expr!(
        engine,
        parse_action_expression(source),
        context,
        "Top",
        nothing,
    )
end

function _map_leaves_mutation_corrupted_compiled(corruption::Symbol)
    compiled = compile_spec(parse_spec(_map_leaves_mutation_source(
        "tree = { \"a\" : \"A\" }; return(tree.map_leaves!() { return(value) })",
    )))
    top = compiled.rules_by_label["Top"]
    edge = only(top.action_edges)
    payload = edge.action_payload
    statements = payload.action_ast.statements
    return_call = last(statements).expr
    chain = only(return_call.args).value
    corrupted_chain = if corruption == :receiver_source
        ActionReceiverMutationChainExpr(
            source = chain.source,
            source_span = chain.source_span,
            receiver = ActionReceiverMutationBindingReference(
                source = "corrupt",
                source_span = chain.receiver.source_span,
                name = chain.receiver.name,
            ),
            mutation = chain.mutation,
            continuation = chain.continuation,
        )
    elseif corruption == :chain_kind
        ActionReceiverMutationChainExpr(
            "corrupt_kind",
            chain.source,
            chain.source_span,
            chain.receiver,
            chain.mutation,
            chain.continuation,
        )
    else
        error("unsupported receiver-mutation corruption: $corruption")
    end
    corrupted_return = ActionCallExpr(
        source = return_call.source,
        source_span = return_call.source_span,
        name = return_call.name,
        source_method = return_call.source_method,
        args = ActionArgument[ActionPositionalArgument(corrupted_chain)],
    )
    corrupted_block = ActionBlock(
        source = payload.action_ast.source,
        source_span = payload.action_ast.source_span,
        statements = ActionStatement[
            statements[1:(end - 1)]...,
            ActionStatement(
                source = last(statements).source,
                source_span = last(statements).source_span,
                expr = corrupted_return,
                drops_value = last(statements).drops_value,
            ),
        ],
    )
    corrupted_payload = CompiledActionPayload(
        role = payload.role,
        line = payload.line,
        source = payload.source,
        code = payload.code,
        lifecycle = payload.lifecycle,
        action_ast = corrupted_block,
        contracts = payload.contracts,
    )
    corrupted_edge = CompiledActionEdge(
        line = edge.line,
        source = edge.source,
        targets = edge.targets,
        regex_index = edge.regex_index,
        child_regex_index = edge.child_regex_index,
        has_parent_regex = edge.has_parent_regex,
        selector_kind = edge.selector_kind,
        authored_selector = edge.authored_selector,
        target_slot_id = edge.target_slot_id,
        source_id = edge.source_id,
        code = edge.code,
        fluent_chain = edge.fluent_chain,
        action_payload = corrupted_payload,
    )
    corrupted_top = LinkedSpecJulia.compiled_rule_with(
        top;
        action_edges = [corrupted_edge],
    )
    return CompiledSpec(
        definition_order = compiled.definition_order,
        compiled_rule_order = compiled.compiled_rule_order,
        rules_by_label = Dict(
            label => label == "Top" ? corrupted_top : rule
            for (label, rule) in pairs(compiled.rules_by_label)
        ),
        redefined_rule_labels = compiled.redefined_rule_labels,
        function_registry = compiled.function_registry,
        dependency_regex_state = compiled.dependency_regex_state,
    )
end

@testset "Julia map-leaves receiver-mutation contract" begin
    @test JULIA_MAP_LEAVES_MUTATION_CONTRACT["contract_id"] ==
          "linkedspec-map-leaves-mutation-v1"
    @test JULIA_WRITE_MAP_LEAVES_COMPOSITION_CONTRACT["contract_id"] ==
          "linkedspec-write-map-leaves-composition-v1"

    @testset "projects the frozen syntax and typed AST" begin
        valid = JULIA_MAP_LEAVES_MUTATION_CONTRACT["valid_syntax_cases"]
        invalid = JULIA_MAP_LEAVES_MUTATION_CONTRACT["invalid_syntax_cases"]
        excluded = JULIA_MAP_LEAVES_MUTATION_CONTRACT["excluded_syntax_cases"]
        @test length(valid) == 4
        @test length(invalid) == 14
        @test length(excluded) == 5

        for fixture in valid
            expression = parse_action_expression(String(fixture["source"]))
            @test expression isa ActionReceiverMutationChainExpr
            @test expression.receiver.kind == "binding_reference"
            @test expression.mutation.kind == "receiver_mutation_call"
            @test expression.mutation.method == "map_leaves"
            @test expression.mutation.source_method == "map_leaves!"
            @test expression.mutation.callback.kind == "block_value"
            @test expression.mutation.callback.body.kind == "action_block"
            @test all(call -> call.kind == "fluent_call", expression.continuation)

            expected = get(fixture, "expected_ast", nothing)
            if expected !== nothing
                actual = to_json(expression)
                for field in ("kind", "source", "source_span", "receiver")
                    @test actual[field] == expected[field]
                end
                for field in (
                    "kind",
                    "method",
                    "source_method",
                    "source",
                    "source_span",
                    "method_span",
                    "args_span",
                )
                    @test actual["mutation"][field] == expected["mutation"][field]
                end
                for field in ("kind", "source", "source_span")
                    @test actual["mutation"]["callback"][field] ==
                          expected["mutation"]["callback"][field]
                    @test actual["mutation"]["callback"]["body"][field] ==
                          expected["mutation"]["callback"]["body"][field]
                end
                @test length(actual["continuation"]) == length(expected["continuation"])
                for (actual_call, expected_call) in
                        zip(actual["continuation"], expected["continuation"])
                    for field in (
                        "kind",
                        "method",
                        "source_method",
                        "source",
                        "source_span",
                        "args_source",
                        "args_span",
                    )
                        @test actual_call[field] == expected_call[field]
                    end
                end
            else
                @test expression.receiver.name == fixture["expected_receiver"]
                @test [call.method for call in expression.continuation] ==
                      fixture["expected_continuation"]
            end
        end

        unicode = "tree.map_leaves!() { note = \"é🙂\"; return(value) }.has_key(\"🙂\")"
        unicode_chain = parse_action_expression(unicode)
        @test unicode_chain.source_span.stop == length(collect(unicode))
        @test unicode_chain.source_span.stop < ncodeunits(unicode)
        unicode_argument = only(only(unicode_chain.continuation).args).value
        @test _map_leaves_mutation_scalar_slice(
            unicode,
            unicode_argument.source_span.start,
            unicode_argument.source_span.stop,
        ) == "\"🙂\""

        for fixture in invalid
            expected = fixture["diagnostic"]
            failure = try
                parse_action_expression(String(fixture["source"]))
                nothing
            catch error
                error
            end
            @test failure isa ActionParseException
            actual = to_json(failure)
            @test actual["code"] == expected["code"]
            @test actual["stage"] == expected["stage"]
            for field in ("start", "end", "unit", "provenance")
                @test actual["source_span"][field] == expected["source_span"][field]
            end
            @test actual["message"] == expected["message"]
        end

        for fixture in excluded
            expression = parse_action_expression(String(fixture["source"]))
            @test !(expression isa ActionReceiverMutationChainExpr)
            if fixture["classification"] == "invalid_identifier_not_receiver_mutation"
                @test expression isa ActionRawExpr
            end
        end

        spaced = runtime_parse(
            _map_leaves_mutation_engine(
                "tree = { \"a\" : \"A\" }; " *
                "return( tree . map_leaves! ( ) { return(value) } . count_keys() )",
            ),
            "xhello",
        )
        @test spaced.value == 1
    end

    @testset "executes every frozen success row by stable id" begin
        sources = Dict(
            "hash_sorted_frames_and_cross_kind_leaf" => raw"""
tree = { "b" : { "z" : "B" }, "a" : "A", "arr" : [1, 2] };
audit = [];
result = tree.map_leaves!() {
 audit += path;
 return(if(str_eq(key, "arr"), ["array-leaf"], else(cat(key, "@", depth, "=", value))))
};
return(array(tree, result, audit))
""",
            "array_index_frames_and_cross_kind_leaf" => raw"""
items = ["A", ["B", "C"], { "h" : "H" }];
audit = [];
result = items.map_leaves!() {
 audit += path;
 return(if(str_eq(index, 2), { "kept" : "hash-leaf" }, else(cat(join_values("/", path), "=", value))))
};
return(array(items, result, audit))
""",
            "replacement_root_kind_not_revisited" => raw"""
tree = { "leaf" : "A" };
audit = [];
result = tree.map_leaves!() { audit += path; return({ "new" : { "deep" : "X" } }) };
return(array(tree, result, audit))
""",
            "callback_path_and_value_are_copied" => raw"""
items = [["A"], "B"];
audit = [];
result = items.map_leaves!() {
 audit += path;
 original = value;
 value = "local";
 path = [99];
 return(cat(original, "*"))
};
return(array(items, result, audit))
""",
            "unrelated_side_effects_persist" => raw"""
tree = { "b" : "B", "a" : "A" };
audit = [];
result = tree.map_leaves!() { audit += path; return(cat(value, "!")) };
return(array(tree, result, audit))
""",
            "unrelated_receiver_mutation_allowed" => raw"""
tree = { "a" : "A" };
other = [];
result = tree.map_leaves!() { other = [value]; return(cat(value, "!")) };
return(array(tree, result, other))
""",
            "empty_hash_commits_without_callback" => raw"""
tree = {};
audit = [];
result = tree.map_leaves!() { audit += "called"; return(value) };
return(array(tree, result, audit))
""",
            "empty_array_commits_without_callback" => raw"""
items = [];
audit = [];
result = items.map_leaves!() { audit += "called"; return(value) };
return(array(items, result, audit))
""",
            "hash_continuation_runs_after_commit" => raw"""
tree = { "b" : "B", "a" : "A" };
audit = [];
result = tree.map_leaves!() { audit += path; return(cat(value, "!")) }.count_keys();
return(array(tree, result, audit))
""",
            "array_continuation_runs_after_commit" => raw"""
items = ["A", "B"];
audit = [];
result = items.map_leaves!() { audit += path; return(cat(value, "!")) }.count();
return(array(items, result, audit))
""",
        )
        expected_extra = Dict(
            "hash_sorted_frames_and_cross_kind_leaf" => Any[Any["a"], Any["arr"], Any["b", "z"]],
            "array_index_frames_and_cross_kind_leaf" => Any[Any[0], Any[1, 0], Any[1, 1], Any[2]],
            "replacement_root_kind_not_revisited" => Any[Any["leaf"]],
            "callback_path_and_value_are_copied" => Any[Any[0, 0], Any[1]],
            "unrelated_side_effects_persist" => Any[Any["a"], Any["b"]],
            "unrelated_receiver_mutation_allowed" => Any["A"],
            "empty_hash_commits_without_callback" => Any[],
            "empty_array_commits_without_callback" => Any[],
            "hash_continuation_runs_after_commit" => Any[Any["a"], Any["b"]],
            "array_continuation_runs_after_commit" => Any[Any[0], Any[1]],
        )
        fixtures = JULIA_MAP_LEAVES_MUTATION_CONTRACT["success_cases"]
        @test Set(String(fixture["id"]) for fixture in fixtures) == Set(keys(sources))
        for fixture in fixtures
            id = String(fixture["id"])
            binding = String(fixture["binding"])
            actual = runtime_parse(
                _map_leaves_mutation_engine(sources[id]),
                "xhello",
            ).value
            @test actual[1] == fixture["expected_bindings"][binding]
            @test actual[2] == fixture["expected_result"]
            @test actual[3] == expected_extra[id]
        end
    end

    @testset "executes every frozen pre-commit failure row by stable id" begin
        fixtures = JULIA_MAP_LEAVES_MUTATION_CONTRACT["failure_cases"]
        @test length(fixtures) == 8
        engine = _map_leaves_mutation_engine("return(undef)")
        for fixture in fixtures
            id = String(fixture["id"])
            expected = fixture["expected_diagnostic"]
            source = String(fixture["source"])
            callback_count = Ref(0)
            injected = RuntimeInterpreterException(
                String(expected["message"]);
                diagnostic = RuntimeDiagnostic(
                    type = "runtime",
                    stage = String(get(expected, "stage", "action_runtime")),
                    summary = String(expected["message"]),
                    detail = String(expected["message"]),
                    code = String(expected["code"]),
                    source_span = expected["source_span"],
                ),
            )
            sink = if id == "callback_failure_is_atomic"
                event -> begin
                    callback_count[] += 1
                    callback_count[] == 2 && throw(injected)
                    nothing
                end
            else
                nothing
            end
            if id == "callback_failure_is_atomic"
                source = "tree.map_leaves!() { audit += path; " *
                         "say(\"callback\"); return(cat(value, \"!\")) }"
            end
            context = _map_leaves_mutation_private_context(
                fixture["initial_bindings"];
                diagnostic_output_sink = sink,
            )
            failure = try
                _map_leaves_mutation_private_evaluate(engine, context, source)
                nothing
            catch error
                error
            end
            if failure isa LinkedSpecJulia._RuntimeDiagnosticOutputSinkFailure
                @test failure.error === injected
                failure = failure.error
            end
            @test failure isa RuntimeInterpreterException
            diagnostic = to_json(failure.diagnostic)
            for field in ("code", "operation", "binding", "method", "attempt", "actual_kind")
                if haskey(expected, field)
                    @test diagnostic[field] == expected[field]
                end
            end
            if haskey(expected, "expected_kinds")
                @test diagnostic["expected_kinds"] == expected["expected_kinds"]
            end
            if id != "callback_failure_is_atomic"
                actual_span = diagnostic["source_span"]
                expected_span = expected["source_span"]
                for field in ("start", "end", "unit", "provenance")
                    @test actual_span[field] == expected_span[field]
                end
                @test diagnostic["detail"] == expected["message"]
            else
                @test failure === injected
                @test callback_count[] == 2
            end
            for (name, value) in pairs(fixture["expected_bindings"])
                @test _map_leaves_mutation_private_value(context, String(name)) == value
            end
            if id == "receiver_absent"
                @test !LinkedSpecJulia._runtime_binding_present(context, "tree")
            end
        end
    end

    @testset "releases the guard and preserves a commit before continuation failure" begin
        engine = _map_leaves_mutation_engine("return(undef)")
        context = _map_leaves_mutation_private_context(
            Dict{String,Any}("tree" => Dict{String,Any}("a" => "A")),
        )
        first_failure = try
            _map_leaves_mutation_private_evaluate(
                engine,
                context,
                "tree.map_leaves!() { tree = {}; return(value) }",
            )
            nothing
        catch error
            error
        end
        @test first_failure isa RuntimeInterpreterException
        @test first_failure.diagnostic.code == "receiver_mutation_reentrant"
        second_result = _map_leaves_mutation_private_evaluate(
            engine,
            context,
            "tree.map_leaves!() { return(cat(value, \"!\")) }",
        )
        @test second_result == Dict{String,Any}("a" => "A!")
        @test _map_leaves_mutation_private_value(context, "tree") == second_result

        continuation_failure = RuntimeInterpreterException(
            "continuation requested failure";
            diagnostic = RuntimeDiagnostic(
                type = "runtime",
                stage = "action_runtime",
                summary = "continuation requested failure",
                detail = "continuation requested failure",
                code = "continuation_failed",
            ),
        )
        continuation_context = _map_leaves_mutation_private_context(
            Dict{String,Any}("tree" => Dict{String,Any}("a" => "A"));
            diagnostic_output_sink = _ -> throw(continuation_failure),
        )
        failure = try
            _map_leaves_mutation_private_evaluate(
                engine,
                continuation_context,
                "tree.map_leaves!() { return(cat(value, \"!\")) }." *
                "with() { say(\"fail\"); return(value) }",
            )
            nothing
        catch error
            error
        end
        @test failure isa LinkedSpecJulia._RuntimeDiagnosticOutputSinkFailure
        unwrapped_failure = failure isa LinkedSpecJulia._RuntimeDiagnosticOutputSinkFailure ?
            failure.error : failure
        @test unwrapped_failure === continuation_failure
        @test _map_leaves_mutation_private_value(continuation_context, "tree") ==
              Dict{String,Any}("a" => "A!")

        discarded = runtime_parse(
            _map_leaves_mutation_engine(
                "tree = { \"a\" : \"A\" }; " *
                "tree.map_leaves!() { return(cat(value, \"!\")) }; return(tree)",
            ),
            "xhello",
        )
        @test discarded.value == Dict{String,Any}("a" => "A!")
    end

    @testset "executes root-kind traversal and post-commit continuation" begin
        hash = runtime_parse(_map_leaves_mutation_engine(raw"""
tree = { "b" : { "z" : "B" }, "a" : "A", "arr" : [1, 2] };
audit = [];
result = tree.map_leaves!() {
 audit += join_values("/", path);
 return(if(str_eq(key, "arr"), ["array-leaf"], else(cat(key, "@", depth, "=", value))))
};
return(array(tree, result, audit))
"""), "xhello")
        expected_hash = Dict{String,Any}(
            "a" => "a@1=A",
            "arr" => Any["array-leaf"],
            "b" => Dict{String,Any}("z" => "z@2=B"),
        )
        @test hash.value == Any[expected_hash, expected_hash, Any["a", "arr", "b/z"]]

        array = runtime_parse(_map_leaves_mutation_engine(raw"""
items = ["A", ["B", "C"], { "h" : "H" }];
result = items.map_leaves!() {
 return(if(str_eq(index, 2), { "kept" : "hash-leaf" }, else(cat(join_values("/", path), "=", value))))
}.count();
return(array(items, result))
"""), "xhello")
        @test array.value == Any[
            Any[
                "0=A",
                Any["1/0=B", "1/1=C"],
                Dict{String,Any}("kept" => "hash-leaf"),
            ],
            3,
        ]
    end

    @testset "detaches frames, replacements, committed root, and result" begin
        frames = runtime_parse(_map_leaves_mutation_engine(raw"""
tree = { "b" : "B", "a" : "A" };
audit = [];
other = [];
mapped = tree.map_leaves!() {
 audit += path;
 other = [value];
 value = "local";
 path = ["changed"];
 return(cat(key, "!"))
};
return(array(tree, mapped, audit, other, value, path))
"""), "xhello")
        @test frames.value == Any[
            Dict{String,Any}("a" => "a!", "b" => "b!"),
            Dict{String,Any}("a" => "a!", "b" => "b!"),
            Any[Any["a"], Any["b"]],
            Any["B"],
            nothing,
            nothing,
        ]

        detached = runtime_parse(_map_leaves_mutation_engine(raw"""
initial = { "leaf" : ["A"] };
tree = initial;
mapped = tree.map_leaves!() { return(array(value.first(), { "nested" : ["B"] })) };
initial["leaf"][0] = "initial-mutated";
mapped["leaf"][0] = "returned-mutated";
tree["leaf"][1]["nested"][0] = "committed-mutated";
return(array(initial, tree, mapped))
"""), "xhello")
        @test detached.value == Any[
            Dict{String,Any}("leaf" => Any["initial-mutated"]),
            Dict{String,Any}(
                "leaf" => Any[
                    "A",
                    Dict{String,Any}("nested" => Any["committed-mutated"]),
                ],
            ),
            Dict{String,Any}(
                "leaf" => Any[
                    "returned-mutated",
                    Dict{String,Any}("nested" => Any["B"]),
                ],
            ),
        ]
    end

    @testset "uses resolved identity for shadow parameters" begin
        engine = _map_leaves_mutation_source_engine(raw"""
fn shadow_write(tree) {
 tree[0]["local"] = "A";
 return(tree)
}

Top::
 -> Done { tree = { "leaf" : [] }; result = tree.map_leaves!() { return(shadow_write(value)) }; return(array(tree, result)) }

Done::
 /[a-z]+/
""")
        expected = Dict{String,Any}(
            "leaf" => Any[Dict{String,Any}("local" => "A")],
        )
        @test runtime_parse(engine, "xhello").value == Any[expected, expected]
    end

    @testset "composes with nested write and preserves non-bang isolation" begin
        callback_write = runtime_parse(_map_leaves_mutation_engine(raw"""
tree = { "leaf" : [] };
result = tree.map_leaves!() { value[0]["name"] = "A"; return(value) };
return(array(tree, result))
"""), "xhello")
        expected = Dict{String,Any}(
            "leaf" => Any[Dict{String,Any}("name" => "A")],
        )
        @test callback_write.value == Any[expected, expected]

        unrelated = runtime_parse(_map_leaves_mutation_engine(raw"""
tree = { "a" : "A" };
result = tree.map_leaves!() { journal["seen"][0] = path; return(cat(value, "!")) };
return(array(tree, result, journal))
"""), "xhello")
        @test unrelated.value == Any[
            Dict{String,Any}("a" => "A!"),
            Dict{String,Any}("a" => "A!"),
            Dict{String,Any}("seen" => Any[Any["a"]]),
        ]

        nonbang = runtime_parse(_map_leaves_mutation_engine(raw"""
tree = { "leaf" : [{ "x" : "original" }] };
result = tree.map_leaves() { value[0]["x"] = "changed"; return(value) };
return(array(tree, result))
"""), "xhello")
        @test nonbang.value == Any[
            Dict{String,Any}(
                "leaf" => Any[Dict{String,Any}("x" => "original")],
            ),
            Dict{String,Any}(
                "leaf" => Any[Dict{String,Any}("x" => "changed")],
            ),
        ]
    end

    @testset "reports receiver and re-entrant failures exactly" begin
        for (action, code, actual_kind) in (
            ("tree.map_leaves!() { return(value) }", "map_leaves_mutation_receiver_missing", nothing),
            ("tree = undef; tree.map_leaves!() { return(value) }", "map_leaves_mutation_receiver_kind_mismatch", "null"),
            ("tree = \"scalar\"; tree.map_leaves!() { return(value) }", "map_leaves_mutation_receiver_kind_mismatch", "string"),
        )
            diagnostic = to_json(_map_leaves_mutation_failure(action).diagnostic)
            @test diagnostic["code"] == code
            @test diagnostic["operation"] == "map_leaves_mutation"
            @test diagnostic["binding"] == "tree"
            @test diagnostic["method"] == "map_leaves"
            if actual_kind !== nothing
                @test diagnostic["actual_kind"] == actual_kind
                @test diagnostic["expected_kinds"] == Any["harray", "array"]
            end
        end

        for (action, attempt, target_source) in (
            ("tree = { \"a\" : \"A\" }; tree.map_leaves!() { tree = {}; return(value) }", "assign", "tree"),
            ("tree = { \"a\" : \"A\" }; tree.map_leaves!() { tree[\"x\"] = value; return(value) }", "nested_write", "tree"),
            ("tree = { \"a\" : \"A\" }; tree.map_leaves!() { set(tree, {}); return(value) }", "helper:set", "set(tree, {})"),
            ("tree = { \"a\" : \"A\" }; tree.map_leaves!() { return(tree.map_leaves!() { return(value) }) }", "map_leaves!", "tree"),
        )
            diagnostic = to_json(_map_leaves_mutation_failure(action).diagnostic)
            @test diagnostic["code"] == "receiver_mutation_reentrant"
            @test diagnostic["attempt"] == attempt
            span = diagnostic["source_span"]
            @test span["unit"] == "unicode_scalar"
            @test span["provenance"] == "authored"
            @test _map_leaves_mutation_scalar_slice(
                action,
                span["start"],
                span["end"],
            ) == target_source
        end
    end

    @testset "guards every binding write before its operands" begin
        cases = (
            ("tree += { say(\"operand\"); \"x\" }", "append"),
            ("tree[{ say(\"operand\"); 0 }] = { say(\"rhs\"); \"x\" }", "nested_write"),
            ("set(tree, { say(\"operand\"); [] })", "helper:set"),
            ("push(tree, { say(\"operand\"); \"x\" })", "helper:push"),
            ("tree.push_back({ say(\"operand\"); \"x\" })", "push_back"),
            ("tree.push_front({ say(\"operand\"); \"x\" })", "push_front"),
            ("tree.pop_back()", "pop_back"),
            ("tree.pop_front()", "pop_front"),
            ("split(tree, { say(\"operand\"); \"a,b\" }, \",\")", "helper:split"),
            ("split_each(tree, { say(\"operand\"); \",\" })", "helper:split_each"),
            ("trim_each(tree)", "helper:trim_each"),
            ("filter_nonempty(tree)", "helper:filter_nonempty"),
            ("filter_match(tree, { say(\"operand\"); /^a/ })", "helper:filter_match"),
            ("lowercase_each(tree)", "helper:lowercase_each"),
            ("uppercase_each(tree)", "helper:uppercase_each"),
            ("uniq(tree)", "helper:uniq"),
            ("substr(tree, { say(\"operand\"); \"a\" }, \"b\")", "helper:substr"),
            ("regex_subst(tree, { say(\"operand\"); /a/ }, \"b\")", "helper:regex_subst"),
        )
        for (attempt_source, expected_attempt) in cases
            events = RuntimeDiagnosticOutputEvent[]
            action = "tree = [\"seed\"]; tree.map_leaves!() { " *
                     "$attempt_source; return(value) }"
            failure = _map_leaves_mutation_failure(
                action;
                diagnostic_output_sink = event -> push!(events, event),
            )
            @test failure.diagnostic.code == "receiver_mutation_reentrant"
            @test failure.diagnostic.attempt == expected_attempt
            @test isempty(events)
        end

        events = RuntimeDiagnosticOutputEvent[]
        failure = _map_leaves_mutation_failure(
            "tree = { \"a\" : \"A\" }; tree.map_leaves!() { " *
            "set_key(tree, { say(\"operand\"); \"x\" }, value); return(value) }";
            diagnostic_output_sink = event -> push!(events, event),
        )
        @test failure.diagnostic.code == "receiver_mutation_reentrant"
        @test failure.diagnostic.attempt == "helper:set_key"
        @test isempty(events)

        pure_substr_statement = runtime_parse(
            _map_leaves_mutation_engine(
                "value = \"a1\"; substr(value, 1, 2); return(value)",
            ),
            "xhello",
        )
        @test pure_substr_statement.value == "a1"
    end

    @testset "propagates callback failure unchanged" begin
        injected = RuntimeInterpreterException(
            "injected callback failure";
            diagnostic = RuntimeDiagnostic(
                type = "runtime",
                stage = "action_runtime",
                summary = "injected callback failure",
                detail = "injected callback failure",
                code = "callback_failed",
            ),
        )
        failure = _map_leaves_mutation_failure(
            "tree = { \"a\" : \"A\" }; " *
            "tree.map_leaves!() { say(\"fail\"); return(value) }";
            diagnostic_output_sink = _ -> throw(injected),
        )
        @test failure === injected
    end

    @testset "rejects malformed typed carriers" begin
        for corruption in (:receiver_source, :chain_kind)
            corrupted = _map_leaves_mutation_corrupted_compiled(corruption)
            validator_failure = try
                validate_receiver_mutation_serialized_state(corrupted)
                nothing
            catch error
                error
            end
            @test validator_failure isa CompiledSpecException
            @test occursin("receiver_mutation_serialized_state_invalid", validator_failure.message)

            runtime_failure = try
                LinkedSpecRuntimeEngine(corrupted)
                nothing
            catch error
                error
            end
            @test runtime_failure isa RuntimeInterpreterException
            @test runtime_failure.diagnostic.code ==
                  "receiver_mutation_serialized_state_invalid"

            emit_failure = try
                emit_julia_source_v2(corrupted, "map-leaves-mutation/corrupt.spec")
                nothing
            catch error
                error
            end
            @test emit_failure isa GeneratedSourceException
            @test occursin("receiver_mutation_serialized_state_invalid", emit_failure.detail)

            plan_failure = try
                validate_generated_rule_plan_v2(
                    corrupted,
                    build_generated_rule_plan(corrupted),
                    "map-leaves-mutation/corrupt.spec",
                )
                nothing
            catch error
                error
            end
            @test plan_failure isa GeneratedSourceException
            @test occursin("receiver_mutation_serialized_state_invalid", plan_failure.detail)
        end
    end

    @testset "typed state survives supported Julia routes" begin
        identity = "map-leaves-mutation/julia.spec"
        source = _map_leaves_mutation_source(
            "tree = { \"b\" : \"B\", \"a\" : \"A\" }; " *
            "return(tree.map_leaves!() { return(cat(value, \"!\")) }.count_keys())",
        )
        expected = 2
        authored = parse_spec(source; source_id = identity)
        reconstructed = from_json(
            SpecFile,
            JSON3.read(JSON3.write(to_json(authored)), Dict{String,Any}),
        )
        compiled = compile_spec(reconstructed)
        compiled_json = String(JSON3.write(to_descriptor_json(compiled)))
        @test occursin("\"kind\":\"receiver_mutation_chain\"", compiled_json)
        @test occursin("\"kind\":\"binding_reference\"", compiled_json)
        @test occursin("\"source_method\":\"map_leaves!\"", compiled_json)
        @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "xhello").value == expected

        plan = build_generated_rule_plan(compiled)
        @test execute_generated_parser_v2(compiled, plan, "xhello", identity) == expected

        output = IOBuffer()
        errors = IOBuffer()
        @test LinkedSpecJulia.run_cli(
            ["--inline-spec", source, "--input", "xhello"];
            io = output,
            err = errors,
        ) == 0
        @test isempty(String(take!(errors)))
        @test JSON3.read(String(take!(output))) == expected

        emitted = emit_julia_source_v2(compiled, identity)
        @test occursin(GENERATED_SOURCE_CONTRACT, emitted)
        scratch = mktempdir()
        try
            generated_path = joinpath(scratch, "map_leaves_mutation_generated.jl")
            write(generated_path, emitted)
            host = Module(gensym(:JuliaMapLeavesMutationGenerated))
            Base.include(host, generated_path)
            parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
            execute = Base.invokelatest(() -> Core.getglobal(parser, :execute))
            @test Base.invokelatest(execute, "xhello") == expected
        finally
            rm(scratch; recursive = true, force = true)
        end
        @test !ispath(scratch)
    end
end
