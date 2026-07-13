const UNIFORM_BINDING_CONTRACT = JSON3.read(
    read(joinpath(REPO_ROOT, "capability_conformance", "uniform_binding_contract.json"), String),
    Dict{String,Any},
)

function _compile_uniform_binding_source(source::AbstractString)
    spec = parse_spec(source)
    validate_spec(spec)
    return compile_spec(spec)
end

function _expect_uniform_binding_native_and_generated(
    source::AbstractString,
    expected;
    input::AbstractString = "xx",
)
    compiled = _compile_uniform_binding_source(source)
    @test runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value == expected
    @test execute_generated_parser_v1(
        compiled,
        build_generated_rule_plan(compiled),
        input,
        "uniform-binding-test.spec",
    ) == expected
end

function _expect_uniform_binding_wrong_kind_fields(
    detail::AbstractString,
    identifier::AbstractString,
    expected_kind::AbstractString,
    actual_kind::AbstractString,
)
    @test occursin("binding_kind_mismatch", detail)
    @test occursin("identifier=$identifier", detail)
    @test occursin("expected_kind=$expected_kind", detail)
    @test occursin("actual_kind=$actual_kind", detail)
end

function _expect_uniform_binding_wrong_kind(
    source::AbstractString,
    identifier::AbstractString,
    expected_kind::AbstractString,
    actual_kind::AbstractString,
)
    compiled = _compile_uniform_binding_source(source)

    native_error = try
        runtime_execute(LinkedSpecRuntimeEngine(compiled), "xx")
        nothing
    catch error
        error
    end
    @test native_error isa RuntimeInterpreterException
    if native_error isa RuntimeInterpreterException
        detail = native_error.diagnostic === nothing ?
            sprint(showerror, native_error) : native_error.diagnostic.detail
        _expect_uniform_binding_wrong_kind_fields(
            detail,
            identifier,
            expected_kind,
            actual_kind,
        )
    end

    generated_error = try
        execute_generated_parser_v1(
            compiled,
            build_generated_rule_plan(compiled),
            "xx",
            "uniform-binding-test.spec",
        )
        nothing
    catch error
        error
    end
    @test generated_error isa GeneratedSourceException
    if generated_error isa GeneratedSourceException
        _expect_uniform_binding_wrong_kind_fields(
            something(generated_error.detail, ""),
            identifier,
            expected_kind,
            actual_kind,
        )
    end
end

function _uniform_binding_action_source(action::AbstractString)
    return "Top::\n /x/ -> Done { $action }\nDone::\n /x/\n"
end

function _uniform_binding_selector_diagnostic(surface, identifier)
    return "aggregate_selector_removed surface=$surface " *
           "identifier=$identifier replacement=$identifier"
end

function _expect_uniform_binding_selector_compile_error(
    source::AbstractString,
    surface::AbstractString,
    identifier::AbstractString;
    staged_functions::Bool = false,
)
    error = try
        spec = staged_functions ?
               parse_spec_with_staged_user_function_definitions(source) : parse_spec(source)
        validate_spec(spec)
        compile_spec(spec)
        nothing
    catch caught
        caught
    end
    @test error isa CompiledSpecException
    if error isa CompiledSpecException
        @test occursin(
            _uniform_binding_selector_diagnostic(surface, identifier),
            error.message,
        )
    end
end

function _uniform_binding_compiled_with_selector_payload()
    compiled = _compile_uniform_binding_source(
        _uniform_binding_action_source("return([])"),
    )
    original = compiled.rules_by_label["Top"]
    action_ast = parse_action_block("array" * "(items)") # selector-rejection fixture: array(items)
    invalid_payload = CompiledActionPayload(
        role = "lifecycle",
        line = 1,
        source = "array selector rejection fixture",
        code = action_ast.source,
        action_ast = action_ast,
        contracts = resolve_action_block_contracts(
            action_ast;
            function_registry = compiled.function_registry,
        ),
    )
    invalid_rule = CompiledRule(
        label = original.label,
        header = original.header,
        mode_metadata = original.mode_metadata,
        regex_patterns = original.regex_patterns,
        dependency_refs = original.dependency_refs,
        action_edges = original.action_edges,
        blind_edges = original.blind_edges,
        lifecycle_action_payloads = [original.lifecycle_action_payloads..., invalid_payload],
        plain_action_payloads = original.plain_action_payloads,
        body_elements = original.body_elements,
    )
    return CompiledSpec(
        definition_order = compiled.definition_order,
        compiled_rule_order = compiled.compiled_rule_order,
        rules_by_label = Dict(compiled.rules_by_label..., "Top" => invalid_rule),
        redefined_rule_labels = compiled.redefined_rule_labels,
        function_registry = compiled.function_registry,
        dependency_regex_state = compiled.dependency_regex_state,
    )
end

@testset "Julia uniform-binding contract" begin
    @testset "exact aggregate selectors fail at the Julia compile boundary" begin
        for case in UNIFORM_BINDING_CONTRACT["invalid_selector_cases"]
            _expect_uniform_binding_selector_compile_error(
                _uniform_binding_action_source(case["source"]),
                case["surface"],
                case["identifier"],
            )
        end
    end

    @testset "dead fluent and unused function selectors also fail compilation" begin
        _expect_uniform_binding_selector_compile_error(
            _uniform_binding_action_source(
                "if(false) { return(array(items)) }; return([])", # selector-rejection fixture
            ),
            "array",
            "items",
        )
        _expect_uniform_binding_selector_compile_error(
            "Top::\n -> Done.return(hash(meta))\nDone::\n /x/\n", # selector-rejection fixture
            "hash",
            "meta",
        )
        _expect_uniform_binding_selector_compile_error(
            "fn retired() { return(array(items)) }\n" * # selector-rejection fixture
            "Top::\n /x/ -> Done { return([]) }\nDone::\n /x/\n",
            "array",
            "items";
            staged_functions = true,
        )
    end

    @testset "generated boundaries reject caller-constructed selector AST" begin
        invalid = _uniform_binding_compiled_with_selector_payload()
        plan = build_generated_rule_plan(invalid)
        diagnostic = _uniform_binding_selector_diagnostic("array", "items")

        emit_error = try
            emit_julia_source_v1(invalid, "selector-generated.spec")
            nothing
        catch caught
            caught
        end
        @test emit_error isa GeneratedSourceException
        if emit_error isa GeneratedSourceException
            @test emit_error.stage == EmitSourceStage
            @test emit_error.code == GeneratedSourceEmitFailedCode
            @test occursin(diagnostic, something(emit_error.detail, ""))
        end

        plan_error = try
            validate_generated_rule_plan_v1(invalid, plan, "selector-generated.spec")
            nothing
        catch caught
            caught
        end
        @test plan_error isa GeneratedSourceException
        if plan_error isa GeneratedSourceException
            @test plan_error.stage == CompileOrLoadGeneratedSourceStage
            @test plan_error.code == GeneratedSourceCompileFailedCode
            @test occursin(diagnostic, something(plan_error.detail, ""))
        end
    end

    @testset "retained aggregate constructors and literals still execute" begin
        _expect_uniform_binding_native_and_generated(
            _uniform_binding_action_source(raw"""
items = ["x"]
left = "l"
right = "r"
key = "key"
value = "r"
return([
  array(),
  array("items"),
  array(copy(items)),
  array(left, right),
  hash(),
  hash("key", value),
  [items],
  { key : value }
])
"""),
            Any[
                Any[],
                Any["items"],
                Any[Any["x"]],
                Any["l", "r"],
                Dict{String,Any}(),
                Dict{String,Any}("key" => "r"),
                Any[Any["x"]],
                Dict{String,Any}("key" => "r"),
            ],
        )
    end

    @testset "future fixture runs natively and through generated execution" begin
        @test UNIFORM_BINDING_CONTRACT["contract_id"] == "linkedspec-uniform-binding-v1"
        fixture = UNIFORM_BINDING_CONTRACT["fixture"]
        _expect_uniform_binding_native_and_generated(
            fixture["spec_source"],
            fixture["expected"];
            input = fixture["input"],
        )
    end

    @testset "absent push and array-end mutation return independent updates" begin
        _expect_uniform_binding_native_and_generated(
            raw"""Top::
 /x/ -> Done {
   first_push = push(items, "a")
   second_push = push(items, "b")
   items += "c"
   count = items.push_back("d").count()
   return({ "items" : items, "first_push" : first_push, "second_push" : second_push, "count" : count })
 }
Done::
 /x/
""",
            Dict{String,Any}(
                "items" => Any["a", "b", "c", "d"],
                "first_push" => Any["a"],
                "second_push" => Any["a", "b"],
                "count" => 4,
            ),
        )
    end

    @testset "registered rule keeps ambiguous push precedence" begin
        _expect_uniform_binding_native_and_generated(
            raw"""Top::
 I { items = ["unchanged"]; outputs = [] }
 /x/ -> Done { pushed = push(items, outputs); return([items, outputs, pushed]) }
items::
 /x/ I { return("child-result") }
Done::
 /x/
""",
            Any[Any["unchanged"], Any["child-result"], Any["child-result"]],
        )
    end

    @testset "mutable and pure split remain distinct" begin
        _expect_uniform_binding_native_and_generated(
            raw"""Top::
 /x/ -> Done {
   stored = split(parts, "a,b", ",")
   pure = split("c,d", ",")
   return({ "parts" : parts, "stored" : stored, "pure" : pure })
 }
Done::
 /x/
""",
            Dict{String,Any}(
                "parts" => Any["a", "b"],
                "stored" => Any["a", "b"],
                "pure" => Any["c", "d"],
            ),
        )
    end

    @testset "hash-index mutation returns the updated harray" begin
        _expect_uniform_binding_native_and_generated(
            raw"""Top::
 /x/ -> Done {
   updated = (meta["stage"] = "ok")
   snapshot = copy(meta)
   return({ "meta" : meta, "updated" : updated, "snapshot" : snapshot })
 }
Done::
 /x/
""",
            Dict{String,Any}(
                "meta" => Dict{String,Any}("stage" => "ok"),
                "updated" => Dict{String,Any}("stage" => "ok"),
                "snapshot" => Dict{String,Any}("stage" => "ok"),
            ),
        )
    end

    @testset "unused values are dropped without changing bindings" begin
        _expect_uniform_binding_native_and_generated(
            raw"""Top::
 /x/ -> Done {
   set(items, ["a"])
   copy(items)
   updated = push(items, "b")
   return({ "items" : items, "updated" : updated })
 }
Done::
 /x/
""",
            Dict{String,Any}(
                "items" => Any["a", "b"],
                "updated" => Any["a", "b"],
            ),
        )
    end

    @testset "bare collection statements rebind the typed array" begin
        _expect_uniform_binding_native_and_generated(
            raw"""Top::
 /x/ -> Done {
   trimmed = trim_each(set(words, [" a ", "", "b"]))
   trim_each(words)
   filter_nonempty(words)
   return({ "trimmed" : trimmed, "words" : words })
 }
Done::
 /x/
""",
            Dict{String,Any}(
                "trimmed" => Any["a", "", "b"],
                "words" => Any["a", "b"],
            ),
        )
    end

    @testset "wrong-kind mutation reports the neutral fields" begin
        _expect_uniform_binding_wrong_kind(
            raw"""Top::
 /x/ -> Done { items = "text"; push(items, "x"); return(items) }
Done::
 /x/
""",
            "items",
            "array",
            "scalar",
        )
    end

    @testset "set returns the assigned value for receiver chaining" begin
        _expect_uniform_binding_native_and_generated(
            raw"""Top::
 /x/ -> Done {
   first = set(items, ["b", "a"]).sorted().first()
   return([first, items])
 }
Done::
 /x/
""",
            Any["a", Any["b", "a"]],
        )
    end

    @testset "I assignment scopes recursive typed bindings per invocation" begin
        _expect_uniform_binding_native_and_generated(
            raw"""top::
 -> sexpr { return(call(sexpr)) }

sexpr: /\(/ /\)/ I { items = [] }
 -> sexpr { push(items, call(sexpr)) }
 -> atom { push(items, call(atom)) }
 -> sexpr[1] { return(copy(items)) }

atom: /[A-Za-z0-9]+/ I.return(entry_text())
""",
            Any["a", Any["b"], "c"];
            input = "(a(b)c)",
        )
    end

    @testset "bare empty rule accumulator reads as an array value" begin
        _expect_uniform_binding_native_and_generated(
            raw"""Top::
 -> Child { return(copy(Child)) }
Child: /x/
""",
            Any[];
            input = "x",
        )
    end
end
