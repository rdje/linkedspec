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

@testset "Julia uniform-binding contract" begin
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
end
