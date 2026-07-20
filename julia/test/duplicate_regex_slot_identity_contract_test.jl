module JuliaDuplicateRegexSlotIdentityAdmission

using JSON3
using LinkedSpecJulia
using Test

const REPO_ROOT = Main.REPO_ROOT

const JULIA_DUPLICATE_SLOT_CONTRACT = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "duplicate_regex_slot_identity_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)

const JULIA_DUPLICATE_SLOT_GENERATED_IDENTITY =
    "duplicate-regex-slot/julia-admission.spec"

function _julia_duplicate_slot_fixtures(contract)
    return Any[row for row in contract["fixtures"]]
end

function _julia_duplicate_slot_fixture(contract, fixture_id::AbstractString)
    return only(
        row for row in _julia_duplicate_slot_fixtures(contract)
        if row["id"] == fixture_id
    )
end

function _julia_duplicate_slot_compile(row)
    return compile_spec(parse_spec(String(row["source"])))
end

function _julia_duplicate_slot_expect_fixture(row; context = "native")
    result = runtime_parse(
        LinkedSpecRuntimeEngine(_julia_duplicate_slot_compile(row)),
        String(row["input"]),
    )
    @test result.value == row["expected_result"]
    @test result.matched
    @test !isempty(String(context))
end

function _julia_duplicate_slot_error(body)
    try
        body()
    catch error
        return error
    end
    return nothing
end

function _julia_duplicate_slot_trace_identities(events)
    identities = String[]
    for event in events
        event.topic == "julia_runtime:regex_slot_selected" || continue
        target_match = match(r"target_rule=([^ ]+)", event.details)
        index_match = match(r"regex_index=([0-9]+)", event.details)
        @test target_match !== nothing
        @test index_match !== nothing
        push!(
            identities,
            "$(only(target_match.captures))#$(only(index_match.captures))",
        )
    end
    return identities
end

function _julia_duplicate_slot_malformed(compiled::CompiledSpec)
    top = compiled_rule(compiled, "Top")
    original = top.action_edges[2]
    malformed_edge = CompiledActionEdge(
        line = original.line,
        source = original.source,
        targets = [DependencyRef(label = "Top", index = 1)],
        regex_index = original.regex_index,
        child_regex_index = 9,
        has_parent_regex = original.has_parent_regex,
        code = original.code,
        fluent_chain = original.fluent_chain,
        action_payload = original.action_payload,
    )
    malformed_top = CompiledRule(
        label = top.label,
        header = top.header,
        mode_metadata = top.mode_metadata,
        regex_patterns = top.regex_patterns,
        dependency_refs = top.dependency_refs,
        action_edges = [top.action_edges[1], malformed_edge],
        blind_edges = top.blind_edges,
        lifecycle_action_payloads = top.lifecycle_action_payloads,
        plain_action_payloads = top.plain_action_payloads,
        body_elements = top.body_elements,
    )
    rules = Dict{String,CompiledRule}(compiled.rules_by_label)
    rules["Top"] = malformed_top
    return CompiledSpec(
        definition_order = compiled.definition_order,
        compiled_rule_order = compiled.compiled_rule_order,
        rules_by_label = rules,
        redefined_rule_labels = compiled.redefined_rule_labels,
        function_registry = compiled.function_registry,
        dependency_regex_state = compiled.dependency_regex_state,
    )
end

function role_neutral_fixtures(contract)
    @test contract["contract_id"] == REGEX_SLOT_IDENTITY_CONTRACT_ID
    @test [row["id"] for row in _julia_duplicate_slot_fixtures(contract)] == [
        "ordered_same_rule_duplicate",
        "choice_same_rule_duplicate",
        "repeated_ordered_duplicate",
        "repeated_non_duplicate_control",
        "ordered_cross_target_duplicate",
    ]
    @test contract["identity"]["required_fields"] == ["target_rule", "regex_index"]
    @test contract["selection"]["ordered"]["algorithm"] ==
          "match_only_the_required_structural_slot_and_report_that_same_identity"

    alternation = RuntimeRegexAlternation(["a", "a"])
    selected = match_runtime_regex_slot(
        alternation,
        1,
        "a",
        0;
        parse_mode = ConsumeParseMode,
    )
    @test selected.alternative_index == 1
    @test selected.pattern == "a"
end

role_native_ordered(contract) = _julia_duplicate_slot_expect_fixture(
    _julia_duplicate_slot_fixture(contract, "ordered_same_rule_duplicate"),
)

role_native_choice(contract) = _julia_duplicate_slot_expect_fixture(
    _julia_duplicate_slot_fixture(contract, "choice_same_rule_duplicate"),
)

role_repeated_ordered(contract) = _julia_duplicate_slot_expect_fixture(
    _julia_duplicate_slot_fixture(contract, "repeated_ordered_duplicate"),
)

role_repeated_control(contract) = _julia_duplicate_slot_expect_fixture(
    _julia_duplicate_slot_fixture(contract, "repeated_non_duplicate_control"),
)

role_cross_target(contract) = _julia_duplicate_slot_expect_fixture(
    _julia_duplicate_slot_fixture(contract, "ordered_cross_target_duplicate"),
)

function role_loaded(contract)
    mktempdir() do scratch
        for row in _julia_duplicate_slot_fixtures(contract)
            path = joinpath(scratch, "$(row["id"]).spec")
            write(path, String(row["source"]))
            loaded = load_and_compile_spec(path_spec_request(path), SpecLoadOptions(scratch))
            result = runtime_parse(create_engine(loaded), String(row["input"]))
            @test result.value == row["expected_result"]
        end
    end
end

function role_reconstructed(contract)
    for row in _julia_duplicate_slot_fixtures(contract)
        parsed = parse_spec(String(row["source"]))
        normalized = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
        result = runtime_parse(
            LinkedSpecRuntimeEngine(compile_spec(normalized)),
            String(row["input"]),
        )
        @test result.value == row["expected_result"]
    end
end

function role_descriptor(contract)
    descriptor_contract = contract["descriptor_contract"]
    for fixture_id in (
        "ordered_same_rule_duplicate",
        "ordered_cross_target_duplicate",
    )
        row = _julia_duplicate_slot_fixture(contract, fixture_id)
        descriptor = to_descriptor_json(_julia_duplicate_slot_compile(row))
        @test descriptor["meta"][String(descriptor_contract["meta_field"])] ==
              descriptor_contract["meta_value"]
        edges = descriptor["spec"]["Top"]["meta"]["resolved_edges"]
        identities = ["$(edge["target"])#$(edge["regex_index"])" for edge in edges]
        @test identities == unique(String[value for value in row["expected_match_identities"]])
    end
end

function role_emitted_source(contract)
    row = _julia_duplicate_slot_fixture(contract, "ordered_same_rule_duplicate")
    emitted = emit_julia_source_v2(
        _julia_duplicate_slot_compile(row),
        JULIA_DUPLICATE_SLOT_GENERATED_IDENTITY,
    )
    @test occursin("linkedspec-generated-source-v2", emitted)
    @test occursin("const LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2", emitted)
    @test occursin("LINKEDSPEC_REGEX_SLOT_IDENTITY_CONTRACT", emitted)
    @test occursin(REGEX_SLOT_IDENTITY_CONTRACT_ID, emitted)
    @test occursin("const _COMPILED_SPEC_JSON_HEX", emitted)
    @test !occursin("regex_text_identity", emitted)

    mktempdir() do scratch
        generated_path = joinpath(scratch, "generated_parser.jl")
        write(generated_path, emitted)
        host = Module(gensym(:JuliaDuplicateSlotAdmissionHost))
        Base.include(host, generated_path)
        parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
        execute = Base.invokelatest(() -> getfield(parser, :execute))
        @test Base.invokelatest(execute, String(row["input"])) ==
              row["expected_result"]
    end
end

function role_generated_direct(contract)
    for row in _julia_duplicate_slot_fixtures(contract)
        compiled = _julia_duplicate_slot_compile(row)
        @test execute_generated_parser_v2(
            compiled,
            build_generated_rule_plan(compiled),
            String(row["input"]),
            JULIA_DUPLICATE_SLOT_GENERATED_IDENTITY,
        ) == row["expected_result"]
    end
end

function role_native_trace(contract)
    ordered = _julia_duplicate_slot_fixture(contract, "repeated_ordered_duplicate")
    ordered_trace = LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceHigh);
        stdout_io = IOBuffer(),
    )
    ordered_result = runtime_parse(
        LinkedSpecRuntimeEngine(_julia_duplicate_slot_compile(ordered)),
        String(ordered["input"]);
        trace = ordered_trace,
    )
    @test ordered_result.value == ordered["expected_result"]
    @test _julia_duplicate_slot_trace_identities(trace_events(ordered_trace)) ==
          String[value for value in ordered["expected_match_identities"]]
    @test all(
        occursin("selection_role=ordered_required", event.details)
        for event in trace_events(ordered_trace)
        if event.topic == "julia_runtime:regex_slot_selected"
    )

    choice = _julia_duplicate_slot_fixture(contract, "choice_same_rule_duplicate")
    choice_trace = LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceHigh);
        stdout_io = IOBuffer(),
    )
    choice_result = runtime_parse(
        LinkedSpecRuntimeEngine(_julia_duplicate_slot_compile(choice)),
        String(choice["input"]);
        trace = choice_trace,
    )
    @test choice_result.value == choice["expected_result"]
    choice_events = [
        event for event in trace_events(choice_trace)
        if event.topic == "julia_runtime:regex_slot_selected"
    ]
    @test length(choice_events) == 1
    @test occursin("selection_role=choice", only(choice_events).details)
end

function role_generated_trace(contract)
    row = _julia_duplicate_slot_fixture(contract, "ordered_cross_target_duplicate")
    compiled = _julia_duplicate_slot_compile(row)
    mktempdir() do scratch
        trace_path = joinpath(scratch, "generated.trace")
        value = execute_generated_parser_with_trace_v2(
            compiled,
            build_generated_rule_plan(compiled),
            String(row["input"]),
            LinkedSpecTraceConfig(
                level = LinkedSpecTraceHigh,
                trace_file = trace_path,
                sink_mode = LinkedSpecTraceRoute,
                reset_file = true,
            ),
            JULIA_DUPLICATE_SLOT_GENERATED_IDENTITY,
        )
        @test value == row["expected_result"]
        trace = read(trace_path, String)
        identities = String[]
        for line in split(trace, '\n')
            occursin("julia_runtime:regex_slot_selected", line) || continue
            target = match(r"target_rule=([^ ]+)", line)
            index = match(r"regex_index=([0-9]+)", line)
            push!(identities, "$(only(target.captures))#$(only(index.captures))")
        end
        @test identities == String[value for value in row["expected_match_identities"]]
    end
end

function role_primary_command(contract)
    for row in _julia_duplicate_slot_fixtures(contract)
        output = IOBuffer()
        error_output = IOBuffer()
        @test run_cli(
            [
                "--inline-spec",
                String(row["source"]),
                "--input",
                String(row["input"]),
            ];
            io = output,
            err = error_output,
        ) == 0
        @test String(take!(output)) == String(JSON3.write(row["expected_result"])) * "\n"
        @test isempty(String(take!(error_output)))
    end
end

function role_invalid_identity_diagnostics(contract)
    expected = Dict(String(row["code"]) => row for row in contract["diagnostics"])

    source_error = _julia_duplicate_slot_error() do
        compile_spec(parse_spec("Top::\n -> Missing[3]\n"))
    end
    @test source_error isa SpecValidationException
    @test source_error.diagnostic.code == "regex_slot_identity_invalid"
    @test source_error.diagnostic.stage == "validate_compiled_rule"
    @test source_error.diagnostic.fields == Dict{String,Any}(
        "rule_label" => "Top",
        "target_rule" => "Missing",
        "regex_index" => 3,
    )

    row = _julia_duplicate_slot_fixture(contract, "ordered_same_rule_duplicate")
    malformed = _julia_duplicate_slot_malformed(_julia_duplicate_slot_compile(row))
    compiled_error = _julia_duplicate_slot_error() do
        validate_compiled_regex_slot_identities(malformed)
    end
    @test compiled_error isa SpecValidationException
    @test to_json(compiled_error.diagnostic) == Dict{String,Any}(
        "code" => "regex_slot_identity_invalid",
        "stage" => "validate_compiled_rule",
        "message" =>
            "rule 'Top' references rule 'Top' regex slot 9, but that structural slot does not exist",
        "fields" => Dict{String,Any}(
            "rule_label" => "Top",
            "target_rule" => "Top",
            "regex_index" => 9,
        ),
    )

    runtime_error = _julia_duplicate_slot_error() do
        LinkedSpecRuntimeEngine(malformed)
    end
    @test runtime_error isa RuntimeInterpreterException
    @test runtime_error.diagnostic.code == "regex_slot_identity_invalid"
    @test runtime_error.diagnostic.stage == "validate_compiled_rule"
    @test runtime_error.diagnostic.rule_label == "Top"
    @test runtime_error.diagnostic.target_rule == "Top"
    @test runtime_error.diagnostic.regex_index == 9

    generated_error = _julia_duplicate_slot_error() do
        validate_generated_rule_plan_v2(
            malformed,
            build_generated_rule_plan(malformed),
            JULIA_DUPLICATE_SLOT_GENERATED_IDENTITY,
        )
    end
    @test generated_error isa GeneratedSourceException
    @test generated_error.stage == ValidateCompiledRuleStage
    @test generated_error.code == RegexSlotIdentityInvalidCode
    @test generated_error.rule_label == "Top"
    @test generated_error.target_rule == "Top"
    @test generated_error.regex_index == 9

    emission_error = _julia_duplicate_slot_error() do
        emit_julia_source_v2(malformed, JULIA_DUPLICATE_SLOT_GENERATED_IDENTITY)
    end
    @test emission_error isa GeneratedSourceException
    @test emission_error.stage == ValidateCompiledRuleStage
    @test emission_error.code == RegexSlotIdentityInvalidCode

    ordered_error = _julia_duplicate_slot_error() do
        assert_ordered_regex_slot_identity(
            rule_label = "Top",
            expected_target_rule = "First",
            expected_regex_index = 0,
            actual_target_rule = "Second",
            actual_regex_index = 0,
        )
    end
    @test ordered_error isa OrderedRegexSlotIdentityException
    @test ordered_error.diagnostic.code == "ordered_regex_slot_identity_lost"
    @test ordered_error.diagnostic.stage == "execute_rule"
    @test Set(keys(ordered_error.diagnostic.fields)) ==
          Set(String(field) for field in expected["ordered_regex_slot_identity_lost"]["fields"])
end

@testset "Contract-declared Julia duplicate regex slot roles execute once and only once" begin
    role_map = Dict{String,Function}(
        "neutral_fixtures" => role_neutral_fixtures,
        "native_ordered" => role_native_ordered,
        "native_choice" => role_native_choice,
        "repeated_ordered" => role_repeated_ordered,
        "repeated_control" => role_repeated_control,
        "cross_target" => role_cross_target,
        "loaded" => role_loaded,
        "reconstructed" => role_reconstructed,
        "descriptor" => role_descriptor,
        "emitted_source" => role_emitted_source,
        "generated_direct" => role_generated_direct,
        "native_trace" => role_native_trace,
        "generated_trace" => role_generated_trace,
        "primary_command" => role_primary_command,
        "invalid_identity_diagnostics" => role_invalid_identity_diagnostics,
    )
    admission = JULIA_DUPLICATE_SLOT_CONTRACT["julia_admission"]
    declared_roles = String[String(role) for role in admission["roles"]]
    @test Set(declared_roles) == Set(keys(role_map))
    @test length(declared_roles) == length(Set(declared_roles))

    completed = Set{String}()
    for role in declared_roles
        @test role ∉ completed
        push!(completed, role)
        role_map[role](JULIA_DUPLICATE_SLOT_CONTRACT)
    end
    @test completed == Set(keys(role_map))
end

end # module JuliaDuplicateRegexSlotIdentityAdmission
