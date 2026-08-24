# FUTURE-PARITY-BACKLOG.14.6.5.0 — dormant Julia progressive-dispatch RED.
#
# This exact final-path consumer is intentionally outside ordinary Julia and
# canonical CI discovery. Its focused repository-local command is:
#
#   bash tools/run_julia_project_data.sh --project=julia --startup-file=no \
#     --history-file=no -e \
#     'using Test; include("julia/test_dormant/progressive_span_dispatch_contract_test.jl")'
#
# The command must report every pre-boundary assertion GREEN and exactly one
# RED at the final dedicated-node assertion until owner .14.6.5.2 lands.

using JSON3
using LinkedSpecJulia
using Test

const JULIA_PROGRESSIVE_REPO_ROOT = normpath(joinpath(@__DIR__, "..", ".."))
const JULIA_PROGRESSIVE_CONTRACT = JSON3.read(
    read(
        joinpath(
            JULIA_PROGRESSIVE_REPO_ROOT,
            "capability_conformance",
            "progressive_span_dispatch_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)
const JULIA_PROGRESSIVE_SOURCE_IDENTITY =
    "progressive-span-dispatch/julia-red.spec"
const JULIA_PROGRESSIVE_EMITTED_IDENTITY =
    "progressive-span-dispatch/julia-red-emitted.spec"
const JULIA_PROGRESSIVE_AUTHORED_SOURCE = raw"""Top::
 I {
  span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored")
  value = dispatch_span("expr-v1", "Expr", span)
  return(value)
 }
 /never/
"""

function _julia_progressive_all_objects(value)
    objects = Dict{String,Any}[]
    if value isa AbstractDict
        object = Dict{String,Any}(String(key) => child for (key, child) in pairs(value))
        push!(objects, object)
        for child in values(object)
            append!(objects, _julia_progressive_all_objects(child))
        end
    elseif value isa AbstractVector
        for child in value
            append!(objects, _julia_progressive_all_objects(child))
        end
    end
    return objects
end

function _julia_progressive_objects_with_kind(value, kind::AbstractString)
    return [
        object for object in _julia_progressive_all_objects(value)
        if get(object, "kind", nothing) == kind
    ]
end

function _julia_progressive_compile(source::AbstractString)
    parsed = parse_spec(source)
    validate_spec(parsed)
    return parsed, compile_spec(parsed)
end

function _julia_progressive_capture(operation::Function)
    try
        operation()
    catch error
        return error
    end
    return nothing
end

function _julia_progressive_expect_native_failure(error)
    @test error isa RuntimeInterpreterException
    error isa RuntimeInterpreterException || return
    @test sprint(showerror, error) ==
          "unsupported runtime helper 'dispatch_span' in rule Top"
    @test error.diagnostic !== nothing
    error.diagnostic === nothing && return
    diagnostic = to_json(error.diagnostic)
    @test diagnostic["stage"] == "runtime_execution"
    @test diagnostic["rule_label"] == "Top"
    @test diagnostic["detail"] ==
          "unsupported runtime helper 'dispatch_span' in rule Top"
end

function _julia_progressive_expect_generated_failure(error, identity::AbstractString)
    @test error isa GeneratedSourceException
    error isa GeneratedSourceException || return
    @test error.stage == ExecuteGeneratedStage
    @test error.code == GeneratedExecutionFailedCode
    @test error.source_identity == identity
    @test error.rule_label == "Top"
    @test error.handler_family == "default"
    @test error.detail == "unsupported runtime helper 'dispatch_span' in rule Top"
end

function _julia_progressive_execute_emitted_failure(
    compiled::CompiledSpec,
    identity::AbstractString,
)
    emitted = emit_julia_source_v2(compiled, identity)
    host = Module(gensym(:JuliaProgressiveDispatchRedHost))
    Base.include_string(host, emitted, "progressive_span_dispatch_generated.jl")
    parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
    execute = Base.invokelatest(() -> getfield(parser, :execute))
    metadata = Base.invokelatest(() -> getfield(parser, :metadata))
    error = _julia_progressive_capture(() -> Base.invokelatest(execute, "abc"))
    source_identity = Base.invokelatest(metadata).source_identity
    return error, emitted, source_identity
end

@testset "Dormant Julia progressive span-dispatch RED" begin
    @testset "neutral inventory and unrelated staged registry are exact" begin
        contract = JULIA_PROGRESSIVE_CONTRACT
        @test contract["contract_id"] == "linkedspec-progressive-span-dispatch-v1"
        @test contract["format"] == 1
        @test contract["status"] ==
              "perl_rust_and_dart_complete_other_backends_pending"
        @test contract["expected_counts"] == Dict{String,Any}(
            "registry_entries" => 2,
            "sources" => 2,
            "view_cases" => 8,
            "authority_cases" => 6,
            "cancellation_cases" => 6,
            "chain_cases" => 8,
            "execution_cases" => 4,
            "rust_carrier_paths" => 9,
            "dart_carrier_paths" => 8,
            "backend_guard_groups" => 2,
            "backend_guard_paths" => 8,
            "outward_guard_paths" => 10,
            "diagnostics" => 26,
            "rollout_legs" => 9,
            "mutations" => 103,
        )
        rollout = contract["rollout"]
        @test [row["leg"] for row in rollout] == [
            "neutral",
            "perl",
            "rust",
            "dart",
            "julia",
            "puc_lua",
            "luajit",
            "recurring",
            "public_no_drift",
        ]
        @test [row["status"] for row in rollout] == [
            "complete",
            "complete",
            "complete",
            "complete",
            "pending",
            "pending",
            "pending",
            "pending",
            "pending",
        ]
        @test rollout[5]["owner"] == "FUTURE-PARITY-BACKLOG.14.6.5"
        @test isempty(rollout[5]["paths"])

        staged_job = StagedParseJob(
            version = 1,
            job_id = "progressive-julia-red",
            parent_ast_path = ["Top"],
            node_kind = "progressive_span_dispatch",
            payload_kind = "source_span",
            text = "a",
            source_span = StagedSourceSpan(0, 1, 1, 1),
            parser_spec_id = "expr-v1",
            top_rule = "Expr",
            result_policy = "replace_field",
            result_field = "value",
            failure_policy = "fail_only",
            diagnostic_owner = "progressive_span_dispatch",
        )
        staged_error = _julia_progressive_capture(
            () -> execute_staged_parse_job(staged_job),
        )
        @test staged_error isa StagedParserRegistryException
        staged_error isa StagedParserRegistryException || return
        @test occursin("phase=resolve", staged_error.message)
        @test occursin("parser_spec_id=expr-v1", staged_error.message)
        @test occursin(
            "unsupported parser spec id 'expr-v1'",
            staged_error.message,
        )
    end

    parsed, compiled = _julia_progressive_compile(JULIA_PROGRESSIVE_AUTHORED_SOURCE)
    top = compiled_rule(compiled, "Top")
    payload = only(action_payloads(top))
    compiled_action = to_json(payload.action_ast)
    generic_calls = [
        object for object in _julia_progressive_objects_with_kind(compiled_action, "call")
        if get(object, "name", nothing) == "dispatch_span"
    ]
    progressive_nodes = _julia_progressive_objects_with_kind(
        compiled_action,
        "progressive_dispatch_span",
    )

    @testset "authored syntax remains one generic unsupported call" begin
        @test length(generic_calls) == 1
        call = only(generic_calls)
        @test length(call["args"]) == 3
        @test call["args"][1]["kind"] == "string"
        @test call["args"][1]["value"] == "expr-v1"
        @test call["args"][2]["kind"] == "string"
        @test call["args"][2]["value"] == "Expr"
        @test call["args"][3]["kind"] == "variable"
        @test call["args"][3]["name"] == "span"
        @test isempty(progressive_nodes)
        encoded = JSON3.write(compiled_action)
        @test occursin("dispatch_span", encoded)
        @test !occursin("PROGRESSIVE_DISPATCH_SPAN", encoded)
    end

    @testset "four carriers converge on the same unsupported-helper boundary" begin
        native_error = _julia_progressive_capture(
            () -> runtime_parse(LinkedSpecRuntimeEngine(compiled), "abc"),
        )
        _julia_progressive_expect_native_failure(native_error)

        normalized = JSON3.read(JSON3.write(to_json(parsed)), Dict{String,Any})
        reconstructed = from_json(SpecFile, normalized)
        validate_spec(reconstructed)
        reconstructed_compiled = compile_spec(reconstructed)
        reconstructed_error = _julia_progressive_capture(
            () -> runtime_parse(
                LinkedSpecRuntimeEngine(reconstructed_compiled),
                "abc",
            ),
        )
        _julia_progressive_expect_native_failure(reconstructed_error)

        generated_error = _julia_progressive_capture(
            () -> execute_generated_parser_v2(
                compiled,
                build_generated_rule_plan(compiled),
                "abc",
                JULIA_PROGRESSIVE_SOURCE_IDENTITY,
            ),
        )
        _julia_progressive_expect_generated_failure(
            generated_error,
            JULIA_PROGRESSIVE_SOURCE_IDENTITY,
        )

        emitted_error, emitted, emitted_identity =
            _julia_progressive_execute_emitted_failure(
                compiled,
                JULIA_PROGRESSIVE_EMITTED_IDENTITY,
            )
        _julia_progressive_expect_generated_failure(
            emitted_error,
            JULIA_PROGRESSIVE_EMITTED_IDENTITY,
        )
        @test emitted_identity == JULIA_PROGRESSIVE_EMITTED_IDENTITY
        @test !occursin("PROGRESSIVE_DISPATCH_SPAN", emitted)
        @test !occursin("ProgressiveExecutionSeed", emitted)
        @test !occursin("ProgressiveRegistryEntry", emitted)
    end

    @testset "consumer stays dormant and fails only at the dedicated node" begin
        ordinary = read(
            joinpath(JULIA_PROGRESSIVE_REPO_ROOT, "julia", "test", "runtests.jl"),
            String,
        )
        canonical = read(
            joinpath(JULIA_PROGRESSIVE_REPO_ROOT, "tools", "run_ci_local.sh"),
            String,
        )
        @test !occursin("progressive_span_dispatch_contract_test.jl", ordinary)
        @test !occursin(
            "julia/test_dormant/progressive_span_dispatch_contract_test.jl",
            canonical,
        )

        # Intentional RED: owner .14.6.5.2 must replace the generic call with
        # exactly one dedicated logical-only node without changing this fixture.
        @test isempty(generic_calls) && length(progressive_nodes) == 1
    end
end
