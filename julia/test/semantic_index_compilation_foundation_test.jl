const SEMANTIC_INTROSPECTION_FIXTURE_ROOT = normpath(
    joinpath(@__DIR__, "..", "..", "capability_conformance", "semantic_introspection"),
)

function _semantic_fixture_source(name)
    return read(joinpath(SEMANTIC_INTROSPECTION_FIXTURE_ROOT, "$(name).spec"), String)
end

function _captured_semantic_outcome_error(call)
    try
        call()
    catch error
        @test error isa SemanticIndexError
        return error
    end
    @test false
    return nothing
end

function _semantic_outcome_plain_json(value)
    if value === nothing || value isa Bool || value isa Integer || value isa AbstractString
        return true
    elseif value isa AbstractVector
        return all(_semantic_outcome_plain_json, value)
    elseif value isa AbstractDict
        return all(key isa AbstractString for key in keys(value)) &&
               all(_semantic_outcome_plain_json, values(value))
    end
    return false
end

function _semantic_outcome_keys(value)
    found = Set{String}()
    if value isa AbstractDict
        for (key, item) in value
            push!(found, String(key))
            union!(found, _semantic_outcome_keys(item))
        end
    elseif value isa AbstractVector
        for item in value
            union!(found, _semantic_outcome_keys(item))
        end
    end
    return found
end

@testset "Semantic index compiled-or-failed foundation" begin
    graph_source = _semantic_fixture_source("graph")
    graph_index = semantic_index(
        graph_source;
        logical_name = "graph.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )

    expected_snapshot = SemanticSnapshot(
        "snapshot:0",
        SemanticCompiledSnapshotState,
        false,
        SemanticSourceTextDetail,
        true,
    )
    @test semantic_snapshot(graph_index) == expected_snapshot
    @test Base.hash(expected_snapshot, UInt(0)) ==
          Base.hash(semantic_snapshot(graph_index), UInt(0))
    @test to_json(semantic_snapshot(graph_index)) == Dict{String,Any}(
        "id" => "snapshot:0",
        "state" => "compiled",
        "has_execution" => false,
        "source_detail_ceiling" => "text",
        "content_digest_available" => true,
    )
    @test repr(graph_index) ==
          "SemanticIndex(source_id=\"source:0\", snapshot_state=\"compiled\", source_detail_ceiling=\"text\", has_execution=false)"
    @test !occursin("graph.spec", repr(graph_index))
    @test !occursin("Top", repr(graph_index))

    expected_authority = SemanticCompilationAuthority(true, true, true)
    @test compilation_authority(graph_index) == expected_authority
    @test Base.hash(expected_authority, UInt(0)) ==
          Base.hash(compilation_authority(graph_index), UInt(0))
    @test to_json(compilation_authority(graph_index)) == Dict{String,Any}(
        "parsed" => true,
        "validated" => true,
        "compiled" => true,
    )
    @test compilation_diagnostic(graph_index) === nothing

    expected_entry = SemanticEntrySelection("Top", "first_authored_marker")
    @test entry_selection(graph_index) == expected_entry
    @test Base.hash(expected_entry, UInt(0)) ==
          Base.hash(entry_selection(graph_index), UInt(0))
    @test to_json(entry_selection(graph_index)) == Dict{String,Any}(
        "label" => "Top",
        "basis" => "first_authored_marker",
    )

    expected_plan = SemanticGeneratedPlanInput(
        contract_id = "linkedspec-generated-source-v2",
        format_version = 2,
        source_identity = "graph.spec",
        rows = (
            SemanticGeneratedPlanRow("Top", "and_acode_seq"),
            SemanticGeneratedPlanRow("Child", "rep_acode"),
        ),
    )
    @test generated_plan_input(graph_index) == expected_plan
    @test Base.hash(expected_plan, UInt(0)) ==
          Base.hash(generated_plan_input(graph_index), UInt(0))
    @test to_json(generated_plan_input(graph_index)) == Dict{String,Any}(
        "contract_id" => "linkedspec-generated-source-v2",
        "format_version" => 2,
        "source_identity" => "graph.spec",
        "rows" => Any[
            Dict{String,Any}("label" => "Top", "family" => "and_acode_seq"),
            Dict{String,Any}("label" => "Child", "family" => "rep_acode"),
        ],
    )
    @test expected_plan.rows isa Tuple
    @test_throws MethodError push!(expected_plan.rows, SemanticGeneratedPlanRow("Other", "default"))

    plan_json = to_json(generated_plan_input(graph_index))
    plan_json["source_identity"] = "mutated.spec"
    plan_json["rows"][1]["label"] = "Mutated"
    @test generated_plan_input(graph_index) == expected_plan

    none_index = semantic_index(
        graph_source;
        logical_name = "graph-none.spec",
        source_detail_ceiling = SemanticSourceNoneDetail,
    )
    @test semantic_snapshot(none_index) == SemanticSnapshot(
        "snapshot:0",
        SemanticCompiledSnapshotState,
        false,
        SemanticSourceNoneDetail,
        false,
    )
    plan_ceiling_error = _captured_semantic_outcome_error(
        () -> generated_plan_input(none_index),
    )
    @test plan_ceiling_error.stage == "apply_source_ceiling"
    @test plan_ceiling_error.code == "semantic_source_detail_forbidden"

    explicit_index = semantic_index(
        graph_source;
        logical_name = "graph-explicit.spec",
        source_detail_ceiling = SemanticSourceIdentityDetail,
        entry_rule = "Child",
    )
    @test entry_selection(explicit_index) ==
          SemanticEntrySelection("Child", "explicit_selector")
    @test generated_plan_input(explicit_index).source_identity == "graph-explicit.spec"

    markerless_index = semantic_index(
        "First:\n /x/\n\nSecond:\n /y/\n";
        logical_name = "markerless.spec",
        source_detail_ceiling = SemanticSourceIdentityDetail,
    )
    @test entry_selection(markerless_index) ==
          SemanticEntrySelection("First", "first_authored_rule")

    calls_index = semantic_index(
        _semantic_fixture_source("calls_and_staging");
        logical_name = "calls_and_staging.spec",
        source_detail_ceiling = SemanticSourceIdentityDetail,
    )
    @test LinkedSpecJulia._semantic_authored_definition_order(calls_index) == (
        (kind = "function", name = "normalize", line = 1),
        (kind = "rule", name = "Top", line = 3),
        (kind = "rule", name = "Done", line = 9),
    )
    @test [row.label for row in generated_plan_input(calls_index).rows] == ["Top", "Done"]
    @test [row.family for row in generated_plan_input(calls_index).rows] == ["default", "default"]

    failed_index = semantic_index(
        _semantic_fixture_source("failed");
        logical_name = "failed.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )
    @test semantic_snapshot(failed_index).state == SemanticFailedCompilationSnapshotState
    @test compilation_authority(failed_index) == SemanticCompilationAuthority(true, false, false)
    expected_failure = SemanticCompilationDiagnostic(
        code = "bare_edge_target_undefined",
        stage = "normalize_edges",
        message = "bare edge in rule 'Top' targets undefined rule 'Missing'",
        fields = ("rule_label" => "Top", "target" => "Missing"),
    )
    @test compilation_diagnostic(failed_index) == expected_failure
    @test Base.hash(expected_failure, UInt(0)) ==
          Base.hash(compilation_diagnostic(failed_index), UInt(0))
    @test entry_selection(failed_index) === nothing
    @test generated_plan_input(failed_index) === nothing

    failure_json = to_json(compilation_diagnostic(failed_index))
    @test failure_json["fields"] == Dict{String,Any}(
        "rule_label" => "Top",
        "target" => "Missing",
    )
    failure_json["fields"]["target"] = "Mutated"
    @test Dict(compilation_diagnostic(failed_index).fields)["target"] == "Missing"

    parse_failure = semantic_index(
        "Top:::\n /x/\n";
        logical_name = "parse-failure.spec",
        source_detail_ceiling = SemanticSourceIdentityDetail,
    )
    @test compilation_authority(parse_failure) == SemanticCompilationAuthority(false, false, false)
    @test compilation_diagnostic(parse_failure).code == "semantic_index_parse_failed"
    @test compilation_diagnostic(parse_failure).stage == "parse_source"
    @test Dict(compilation_diagnostic(parse_failure).fields) == Dict{String,Any}("line" => 1)

    empty_failure = semantic_index(
        "";
        logical_name = "empty.spec",
        source_detail_ceiling = SemanticSourceIdentityDetail,
    )
    @test compilation_authority(empty_failure) == SemanticCompilationAuthority(true, false, false)
    @test compilation_diagnostic(empty_failure) == SemanticCompilationDiagnostic(
        code = "no_rules_defined",
        stage = "validate_spec",
        message = "spec does not define any rules",
    )

    missing_entry = semantic_index(
        "Top::\n /x/\n";
        logical_name = "missing-entry.spec",
        source_detail_ceiling = SemanticSourceIdentityDetail,
        entry_rule = "Missing",
    )
    @test compilation_authority(missing_entry) == SemanticCompilationAuthority(true, true, false)
    @test compilation_diagnostic(missing_entry) == SemanticCompilationDiagnostic(
        code = "entry_rule_not_found",
        stage = "select_entry_rule",
        message = "entry rule 'Missing' is not defined",
        fields = ("entry_rule" => "Missing",),
    )
    @test entry_selection(missing_entry) === nothing
    @test generated_plan_input(missing_entry) === nothing

    compile_fallback = LinkedSpecJulia._semantic_language_diagnostic(
        CompiledSpecException("compile fallback"),
        "semantic_index_compilation_failed",
        "compile_source",
    )
    @test compile_fallback.code == "semantic_index_compilation_failed"
    @test compile_fallback.stage == "compile_source"
    @test compile_fallback.message == "compile fallback"
    plan_fallback = LinkedSpecJulia._semantic_language_diagnostic(
        ArgumentError("plan fallback"),
        "semantic_index_generated_plan_failed",
        "build_generated_plan",
    )
    @test plan_fallback.code == "semantic_index_generated_plan_failed"
    @test plan_fallback.stage == "build_generated_plan"
    @test plan_fallback.message == "ArgumentError: plan fallback"
    @test LinkedSpecJulia._semantic_is_fatal_exception(InterruptException())
    @test LinkedSpecJulia._semantic_is_fatal_exception(OutOfMemoryError())
    @test LinkedSpecJulia._semantic_is_fatal_exception(StackOverflowError())
    @test !LinkedSpecJulia._semantic_is_fatal_exception(ErrorException("ordinary"))

    bytes_index = semantic_index(
        Vector{UInt8}(codeunits(graph_source));
        logical_name = "graph.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )
    @test semantic_snapshot(bytes_index) == semantic_snapshot(graph_index)
    @test compilation_authority(bytes_index) == compilation_authority(graph_index)
    @test entry_selection(bytes_index) == entry_selection(graph_index)
    @test generated_plan_input(bytes_index) == generated_plan_input(graph_index)

    runtime_index = semantic_index(
        _semantic_fixture_source("runtime");
        logical_name = "runtime.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )
    @test semantic_snapshot(runtime_index).state == SemanticCompiledSnapshotState
    @test semantic_snapshot(runtime_index).has_execution === false
    @test generated_plan_input(runtime_index).rows ==
          (SemanticGeneratedPlanRow("Top", "rep_acode"),)

    public_json = Any[
        to_json(semantic_snapshot(graph_index)),
        to_json(compilation_authority(graph_index)),
        to_json(entry_selection(graph_index)),
        to_json(generated_plan_input(graph_index)),
        to_json(compilation_diagnostic(failed_index)),
    ]
    @test all(_semantic_outcome_plain_json, public_json)
    forbidden_keys = Set([
        "ast",
        "body_ast",
        "compiled_spec",
        "definition_order",
        "descriptor",
        "path",
        "rules_by_label",
        "source_bytes",
        "source_text",
    ])
    @test isempty(reduce(union, (_semantic_outcome_keys(value) for value in public_json)) ∩ forbidden_keys)
    @test isdefined(LinkedSpecJulia, :semantic_query)
    @test !isdefined(LinkedSpecJulia, :semantic_records)

    implementation = read(
        joinpath(@__DIR__, "..", "src", "semantic", "SemanticCompilationOutcome.jl"),
        String,
    )
    @test length(collect(eachmatch(r"parse_spec_with_staged_user_function_definitions\(source_text\)", implementation))) == 1
    @test length(collect(eachmatch(r"validate_spec\(parsed\)", implementation))) == 1
    @test length(collect(eachmatch(r"compile_spec\(parsed; validate_source = false\)", implementation))) == 1
    @test length(collect(eachmatch(r"resolve_entry_rule\(candidate, options\.entry_rule\)", implementation))) == 1
    @test length(collect(eachmatch(r"build_generated_rule_plan\(candidate\)", implementation))) == 1
    for forbidden in (
        "SpecLoader",
        "load_spec(",
        "runtime_parse(",
        "runtime_execute(",
        "execute_generated_parser",
        "LinkedSpecTraceEmitter",
        "diagnostic_output_sink",
        "semantic_observation",
        "to_descriptor_json",
    )
        @test !occursin(forbidden, implementation)
    end
    @test occursin("error isa InterruptException", implementation)
    @test occursin("error isa OutOfMemoryError", implementation)
    @test occursin("error isa StackOverflowError", implementation)
end
