# FUTURE-PARITY-BACKLOG.14.6.5.3 — admitted Julia progressive carriers.
#
# Ordinary `Pkg.test()` discovery and canonical CI both run this exact
# final-path consumer. Its focused repository-local command is:
#
#   bash tools/run_julia_project_data.sh --project=julia --startup-file=no \
#     --history-file=no -e \
#     'using LinkedSpecJulia, JSON3, Test; include("julia/test/progressive_span_dispatch_contract_test.jl")'

using JSON3
using LinkedSpecJulia
using Test

const JuliaProgressiveCarrierAuthority = getproperty(
    LinkedSpecJulia,
    :BoundedChildParseAuthority,
)
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
const JULIA_PROGRESSIVE_FINGERPRINT = "sha256:" * repeat("1", 64)
const JULIA_PROGRESSIVE_EXPECTED_VALUE = Dict{String,Any}(
    "kind" => "identifier",
    "text" => "a",
)
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
        object = Dict{String,Any}(
            String(key) => child for (key, child) in pairs(value)
        )
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

function _julia_progressive_expect_code(operation::Function, code::AbstractString)
    error = _julia_progressive_capture(operation)
    @test error isa JuliaProgressiveCarrierAuthority.ProgressiveDispatchException
    error isa JuliaProgressiveCarrierAuthority.ProgressiveDispatchException ||
        return nothing
    @test JuliaProgressiveCarrierAuthority.diagnostic_code(error) == code
    return error
end

function _julia_progressive_execution_seed(input::AbstractString)
    ceilings = JuliaProgressiveCarrierAuthority.ProgressiveCeilings(
        source_detail = JuliaProgressiveCarrierAuthority.ProgressiveText,
        policy_modes = ["deterministic", "fail-only"],
        max_steps = 100,
        max_result_nodes = 100,
        max_diagnostic_bytes = 4_096,
    )
    registry = JuliaProgressiveCarrierAuthority.ProgressiveRegistry(
        entries = [
            JuliaProgressiveCarrierAuthority.ProgressiveRegistryEntry(
                parser_id = "expr-v1",
                compiled_authority = request -> Dict{String,Any}(
                    "kind" => "identifier",
                    "text" => JuliaProgressiveCarrierAuthority.view_text(
                        request.source_view,
                    ),
                ),
                fingerprint = JULIA_PROGRESSIVE_FINGERPRINT,
                allowed_top_rules = ["Expr"],
                capabilities = ["parse"],
                ceilings = ceilings,
            ),
        ],
    )
    return JuliaProgressiveCarrierAuthority.ProgressiveExecutionSeed(
        registry = registry,
        invocation = JuliaProgressiveCarrierAuthority.ProgressiveInvocationConfig(
            sources = Dict{String,String}("input" => String(input)),
            source_id = "input",
            cancellation_token =
                JuliaProgressiveCarrierAuthority.ProgressiveCancellationToken(),
            clock = JuliaProgressiveCarrierAuthority.ProgressiveClock(() -> 0),
            deadline_tick = 100,
            remaining_steps = 100,
            max_depth = 8,
            max_calls = 16,
        ),
        caller_capabilities = ["parse"],
        required_capabilities = ["parse"],
        caller_ceilings = ceilings,
        required_source_detail = JuliaProgressiveCarrierAuthority.ProgressiveNone,
        dispatch_cost = 1,
    )
end

function _julia_progressive_execute_emitted(
    compiled::CompiledSpec,
    identity::AbstractString,
    seed,
)
    emitted = emit_julia_source_v2(compiled, identity)
    host = Module(gensym(:JuliaProgressiveDispatchCarrierHost))
    Base.include_string(host, emitted, "progressive_span_dispatch_generated.jl")
    parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
    execute = Base.invokelatest(() -> getfield(parser, :execute))
    metadata = Base.invokelatest(() -> getfield(parser, :metadata))
    value = Base.invokelatest(
        execute,
        "abc";
        bounded_child_parse_authority = seed,
    )
    source_identity = Base.invokelatest(metadata).source_identity
    return value, emitted, source_identity
end

@testset "Admitted Julia progressive span-dispatch carriers" begin
    @testset "neutral inventory and unrelated staged registry are exact" begin
        contract = JULIA_PROGRESSIVE_CONTRACT
        @test contract["contract_id"] ==
              "linkedspec-progressive-span-dispatch-v1"
        @test contract["format"] == 1
        @test contract["status"] ==
              "perl_rust_dart_and_julia_complete_other_backends_pending"
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
            "julia_carrier_paths" => 9,
            "lua_dormant_carrier_paths" => 9,
            "backend_guard_groups" => 0,
            "backend_guard_paths" => 0,
            "outward_guard_paths" => 10,
            "diagnostics" => 26,
            "rollout_legs" => 9,
            "mutations" => 106,
        )
        rollout = contract["rollout"]
        @test [row["status"] for row in rollout] == [
            "complete",
            "complete",
            "complete",
            "complete",
            "complete",
            "pending",
            "pending",
            "pending",
            "pending",
        ]
        @test rollout[5]["owner"] == "FUTURE-PARITY-BACKLOG.14.6.5"
        @test rollout[5]["paths"] ==
              ["julia/test/progressive_span_dispatch_contract_test.jl"]

        staged_job = StagedParseJob(
            version = 1,
            job_id = "progressive-julia-carrier",
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

    parsed, compiled = _julia_progressive_compile(
        JULIA_PROGRESSIVE_AUTHORED_SOURCE,
    )
    top = compiled_rule(compiled, "Top")
    payload = only(action_payloads(top))
    compiled_action = to_json(payload.action_ast)
    generic_calls = [
        object for object in _julia_progressive_objects_with_kind(
            compiled_action,
            "call",
        )
        if get(object, "name", nothing) == "dispatch_span"
    ]
    progressive_nodes = _julia_progressive_objects_with_kind(
        compiled_action,
        "progressive_dispatch_span",
    )

    @testset "authored syntax compiles to one exclusive logical-only node" begin
        @test isempty(generic_calls)
        @test length(progressive_nodes) == 1
        node = only(progressive_nodes)
        @test node["target"] == "value"
        @test node["parser_id"] == "expr-v1"
        @test node["top_rule"] == "Expr"
        @test node["span"] == "span"
        encoded = JSON3.write(compiled_action)
        @test !occursin("\"name\":\"dispatch_span\"", encoded)
        @test count("\"kind\":\"progressive_dispatch_span\"", encoded) == 1
        @test !occursin("PROGRESSIVE_DISPATCH_SPAN", encoded)
        @test !occursin(JULIA_PROGRESSIVE_FINGERPRINT, encoded)
        @test !occursin("ProgressiveExecutionSeed", encoded)
        @test !occursin("ProgressiveRegistryEntry", encoded)
    end

    @testset "malformed residual and recognition-reachable forms reject" begin
        malformed = [
            (
                raw"""Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span(parser_id, "Expr", span) } /never/""",
                "progressive_parser_identity_literal_required",
            ),
            (
                raw"""Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("Expr/V1", "Expr", span) } /never/""",
                "progressive_parser_identity_invalid",
            ),
            (
                raw"""Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", top_rule, span) } /never/""",
                "progressive_top_rule_literal_required",
            ),
            (
                raw"""Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", "Bad-Rule", span) } /never/""",
                "progressive_top_rule_invalid",
            ),
            (
                raw"""Top:: I { value = dispatch_span("expr-v1", "Expr", hash("source_id", "input")) } /never/""",
                "progressive_span_binding_required",
            ),
            (
                raw"""Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); return(cat(dispatch_span("expr-v1", "Expr", span))) } /never/""",
                "progressive_span_binding_required",
            ),
            (
                raw"""Top:: I { tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); recognition_rollback(tx); return(matched) }
Child:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", "Expr", span); return(value) } /never/""",
                "recognition_effect_forbidden:parser_registry_or_staged_dispatch",
            ),
        ]
        for (source, code) in malformed
            error = _julia_progressive_capture(
                () -> _julia_progressive_compile(source),
            )
            @test error !== nothing
            @test occursin(code, sprint(showerror, error))
        end
    end

    @testset "live recognition transaction rejects defensively" begin
        source = raw"""Top::
 I {
  tx = recognition_checkpoint()
  span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored")
  value = dispatch_span("expr-v1", "Expr", span)
  recognition_rollback(tx)
  return(value)
 }
 /never/
"""
        _, transaction_compiled = _julia_progressive_compile(source)
        _julia_progressive_expect_code(
            () -> runtime_parse(
                LinkedSpecRuntimeEngine(
                    transaction_compiled;
                    bounded_child_parse_authority =
                        _julia_progressive_execution_seed("abc"),
                ),
                "abc",
            ),
            "progressive_transaction_forbidden",
        )
    end

    @testset "native reconstructed and generated routes use fresh authority" begin
        seed = _julia_progressive_execution_seed("abc")
        @test sprint(show, seed) == "ProgressiveExecutionSeed(<opaque>)"
        @test JuliaProgressiveCarrierAuthority.start(seed) !==
              JuliaProgressiveCarrierAuthority.start(seed)
        _julia_progressive_expect_code(
            () -> runtime_parse(LinkedSpecRuntimeEngine(compiled), "abc"),
            "progressive_registry_missing",
        )

        native = LinkedSpecRuntimeEngine(
            compiled;
            bounded_child_parse_authority = seed,
        )
        native_result = runtime_parse(native, "abc")
        @test native_result.value == JULIA_PROGRESSIVE_EXPECTED_VALUE
        @test native_result.cursor_char_offset == 0
        @test runtime_parse(native, "abc").value ==
              JULIA_PROGRESSIVE_EXPECTED_VALUE

        normalized = JSON3.read(JSON3.write(to_json(parsed)), Dict{String,Any})
        reconstructed = from_json(SpecFile, normalized)
        validate_spec(reconstructed)
        reconstructed_compiled = compile_spec(reconstructed)
        @test runtime_parse(
            LinkedSpecRuntimeEngine(
                reconstructed_compiled;
                bounded_child_parse_authority =
                    _julia_progressive_execution_seed("abc"),
            ),
            "abc",
        ).value == JULIA_PROGRESSIVE_EXPECTED_VALUE

        @test execute_generated_parser_v2(
            compiled,
            build_generated_rule_plan(compiled),
            "abc",
            JULIA_PROGRESSIVE_SOURCE_IDENTITY;
            bounded_child_parse_authority =
                _julia_progressive_execution_seed("abc"),
        ) == JULIA_PROGRESSIVE_EXPECTED_VALUE
    end

    @testset "independently included emitted module carries logical state only" begin
        value, emitted, emitted_identity = _julia_progressive_execute_emitted(
            compiled,
            JULIA_PROGRESSIVE_EMITTED_IDENTITY,
            _julia_progressive_execution_seed("abc"),
        )
        @test value == JULIA_PROGRESSIVE_EXPECTED_VALUE
        @test emitted_identity == JULIA_PROGRESSIVE_EMITTED_IDENTITY
        @test !occursin(JULIA_PROGRESSIVE_FINGERPRINT, emitted)
        @test !occursin("ProgressiveCompiledAuthority", emitted)
        @test !occursin("ProgressiveRegistryEntry", emitted)
        @test !occursin("ProgressiveCancellationToken", emitted)
        @test !occursin("PROGRESSIVE_DISPATCH_SPAN", emitted)
        @test count("progressive_dispatch_span", emitted) == 0
    end

    @testset "consumer is admitted once while authority stays private" begin
        ordinary = read(
            joinpath(JULIA_PROGRESSIVE_REPO_ROOT, "julia", "test", "runtests.jl"),
            String,
        )
        canonical = read(
            joinpath(JULIA_PROGRESSIVE_REPO_ROOT, "tools", "run_ci_local.sh"),
            String,
        )
        @test isfile(joinpath(@__DIR__, "progressive_span_dispatch_contract_test.jl")) &&
              !isfile(
                  joinpath(
                      JULIA_PROGRESSIVE_REPO_ROOT,
                      "julia",
                      "test_dormant",
                      "progressive_span_dispatch_contract_test.jl",
                  ),
              )
        @test count(
            ==("include(\"progressive_span_dispatch_contract_test.jl\")"),
            split(ordinary, '\n'),
        ) == 1
        @test [
            count(
                "require_tracked_file julia/test/progressive_span_dispatch_contract_test.jl",
                canonical,
            ),
            count(
                "running exact Julia progressive span-dispatch admission consumer",
                canonical,
            ),
            count(
                "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/progressive_span_dispatch_contract_test.jl\")'",
                canonical,
            ),
        ] == fill(1, 3)
        @test :ActionProgressiveDispatchSpanExpr ∉ names(LinkedSpecJulia) &&
              isempty(generic_calls)
        @test length(progressive_nodes) == 1
        @test JULIA_PROGRESSIVE_CONTRACT["rollout"][5]["status"] == "complete" &&
              JULIA_PROGRESSIVE_CONTRACT["rollout"][5]["paths"] ==
              ["julia/test/progressive_span_dispatch_contract_test.jl"]
    end
end
