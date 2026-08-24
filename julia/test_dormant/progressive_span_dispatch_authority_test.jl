# FUTURE-PARITY-BACKLOG.14.6.5.1 — private Julia progressive authority.
#
# Ordinary `Pkg.test()` and canonical CI discovery ignore test_dormant/. Run
# this focused proof through repository-local project data:
#
#   bash tools/run_julia_project_data.sh --project=julia --startup-file=no \
#     --history-file=no -e \
#     'using Test; include("julia/test_dormant/progressive_span_dispatch_authority_test.jl")'
#
# The separate final-path consumer remains intentionally RED until `.14.6.5.2`
# adds its dedicated node and four execution carriers.

using JSON3
using LinkedSpecJulia
using Test

const JuliaProgressiveAuthority = getproperty(
    LinkedSpecJulia,
    :BoundedChildParseAuthority,
)
const JULIA_PROGRESSIVE_AUTHORITY_ROOT = normpath(joinpath(@__DIR__, "..", ".."))
const JULIA_PROGRESSIVE_AUTHORITY_CONTRACT = JSON3.read(
    read(
        joinpath(
            JULIA_PROGRESSIVE_AUTHORITY_ROOT,
            "capability_conformance",
            "progressive_span_dispatch_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)
const JULIA_PROGRESSIVE_AUTHORITY_ORIGIN =
    "progressive_span_dispatch_authority"

_julia_progressive_authority_rows(field::AbstractString) =
    JULIA_PROGRESSIVE_AUTHORITY_CONTRACT[String(field)]

function _julia_progressive_authority_ceilings(value::AbstractDict)
    return JuliaProgressiveAuthority.ProgressiveCeilings(
        source_detail = JuliaProgressiveAuthority.parse_source_detail(
            value["source_detail"],
        ),
        policy_modes = value["policy_modes"],
        max_steps = value["max_steps"],
        max_result_nodes = value["max_result_nodes"],
        max_diagnostic_bytes = value["max_diagnostic_bytes"],
    )
end

_julia_progressive_authority_permissive_ceilings() =
    JuliaProgressiveAuthority.ProgressiveCeilings(
        source_detail = JuliaProgressiveAuthority.ProgressiveText,
        policy_modes = ["deterministic", "fail-only", "strict-json", "trace"],
        max_steps = 1_000,
        max_result_nodes = 1_000,
        max_diagnostic_bytes = 4_096,
    )

function _julia_progressive_authority_registry(callback)
    return JuliaProgressiveAuthority.ProgressiveRegistry(
        entries = [
            JuliaProgressiveAuthority.ProgressiveRegistryEntry(
                parser_id = row["parser_id"],
                compiled_authority = callback,
                fingerprint = row["fingerprint"],
                allowed_top_rules = row["allowed_top_rules"],
                capabilities = row["capabilities"],
                ceilings = _julia_progressive_authority_ceilings(row["ceilings"]),
            )
            for row in _julia_progressive_authority_rows("registry_entries")
        ],
    )
end

function _julia_progressive_authority_invocation_config(;
    source_id::AbstractString,
    token,
    now_tick::Int,
    deadline_tick::Int,
    remaining_steps::Int,
    max_depth::Int = 8,
    total_calls::Int = 0,
    max_calls::Int = 16,
    active_chain = JuliaProgressiveAuthority.ProgressiveChainFrame[],
)
    return JuliaProgressiveAuthority.ProgressiveInvocationConfig(
        sources = Dict{String,String}(
            row["id"] => row["text"]
            for row in _julia_progressive_authority_rows("sources")
        ),
        source_id = String(source_id),
        cancellation_token = token,
        clock = JuliaProgressiveAuthority.ProgressiveClock(() -> now_tick),
        deadline_tick = deadline_tick,
        remaining_steps = remaining_steps,
        max_depth = max_depth,
        max_calls = max_calls,
        active_chain = active_chain,
        total_calls = total_calls,
    )
end

function _julia_progressive_authority_arguments(;
    parser_id,
    top_rule,
    span,
    token,
    cost::Int,
    caller_capabilities = [
        "actionir-v1",
        "caller-only",
        "structured-result-v1",
        "typed-source-location-v1",
    ],
    required_capabilities = String[],
    caller_ceilings = _julia_progressive_authority_permissive_ceilings(),
    required_source_detail = JuliaProgressiveAuthority.ProgressiveNone,
    transaction_active::Bool = false,
)
    return JuliaProgressiveAuthority.ProgressiveDispatchArguments(
        origin = JULIA_PROGRESSIVE_AUTHORITY_ORIGIN,
        parser_id = parser_id,
        top_rule = top_rule,
        span = span,
        caller_capabilities = caller_capabilities,
        required_capabilities = required_capabilities,
        caller_ceilings = caller_ceilings,
        required_source_detail = required_source_detail,
        child_token = token,
        cost = cost,
        transaction_active = transaction_active,
    )
end

function _julia_progressive_authority_capture(operation::Function)
    try
        operation()
    catch error
        return error
    end
    return nothing
end

function _julia_progressive_authority_remember!(observed, operation::Function)
    error = _julia_progressive_authority_capture(operation)
    @test error isa JuliaProgressiveAuthority.ProgressiveDispatchException
    error isa JuliaProgressiveAuthority.ProgressiveDispatchException || return nothing
    code = JuliaProgressiveAuthority.diagnostic_code(error)
    observed[code] = JuliaProgressiveAuthority.to_json(error)
    return code
end

function _julia_progressive_authority_deepcopy(value)
    return JSON3.read(JSON3.write(value), Dict{String,Any})
end

@testset "Dormant Julia progressive span-dispatch authority" begin
    @testset "neutral matrix and all 26 diagnostics are exact" begin
        observed = Dict{String,Dict{String,Any}}()

        view_registry = _julia_progressive_authority_registry(request -> begin
            text = JuliaProgressiveAuthority.view_text(request.source_view)
            return Dict{String,Any}(
                "text" => text,
                "offsets" => [
                    JuliaProgressiveAuthority.local_to_global(
                        request.source_view,
                        offset,
                    )
                    for offset in 0:length(text)
                ],
            )
        end)
        for row in _julia_progressive_authority_rows("view_cases")
            token = JuliaProgressiveAuthority.ProgressiveCancellationToken()
            invocation = JuliaProgressiveAuthority.start_invocation(
                view_registry,
                _julia_progressive_authority_invocation_config(
                    source_id = row["authority_source_id"],
                    token = token,
                    now_tick = 1,
                    deadline_tick = 100,
                    remaining_steps = 100,
                ),
            )
            arguments = _julia_progressive_authority_arguments(
                parser_id = "expr-v1",
                top_rule = "Expr",
                span = row["span"],
                token = token,
                cost = 1,
            )
            if row["accepted"]
                result = JuliaProgressiveAuthority.dispatch(invocation, arguments)
                @test result["text"] == row["view_text"]
                @test result["offsets"] == row["local_to_global"]
            else
                @test _julia_progressive_authority_remember!(
                    observed,
                    () -> JuliaProgressiveAuthority.dispatch(invocation, arguments),
                ) == row["diagnostic"]
            end
        end

        for row in _julia_progressive_authority_rows("authority_cases")
            effective_seen = Ref{Any}(nothing)
            authority_registry = _julia_progressive_authority_registry(request -> begin
                effective_seen[] = JuliaProgressiveAuthority.to_json(request.effective)
                return false
            end)
            token = JuliaProgressiveAuthority.ProgressiveCancellationToken()
            entry_id = row["entry_id"]
            invocation = JuliaProgressiveAuthority.start_invocation(
                authority_registry,
                _julia_progressive_authority_invocation_config(
                    source_id = "unicode",
                    token = token,
                    now_tick = 1,
                    deadline_tick = 100,
                    remaining_steps = 100,
                ),
            )
            arguments = _julia_progressive_authority_arguments(
                parser_id = entry_id,
                top_rule = entry_id == "json-v1" ? "Document" : "Expr",
                span = Dict{String,Any}(
                    "source_id" => "unicode",
                    "start" => 0,
                    "end" => 1,
                    "provenance" => "authority-case",
                ),
                token = token,
                cost = 1,
                caller_capabilities = row["caller_capabilities"],
                required_capabilities = row["required_capabilities"],
                caller_ceilings = _julia_progressive_authority_ceilings(
                    row["caller_ceilings"],
                ),
                required_source_detail =
                    JuliaProgressiveAuthority.parse_source_detail(
                        row["required_source_detail"],
                    ),
            )
            if row["accepted"]
                @test JuliaProgressiveAuthority.dispatch(invocation, arguments) === false
                @test effective_seen[] == row["effective"]
            else
                @test _julia_progressive_authority_remember!(
                    observed,
                    () -> JuliaProgressiveAuthority.dispatch(invocation, arguments),
                ) == row["diagnostic"]
            end
        end

        success_registry = _julia_progressive_authority_registry(_ -> true)
        for row in _julia_progressive_authority_rows("cancellation_cases")
            token = JuliaProgressiveAuthority.ProgressiveCancellationToken()
            row["cancelled"] && JuliaProgressiveAuthority.cancel!(token)
            child_token = row["token"] == row["child_token"] ? token :
                JuliaProgressiveAuthority.ProgressiveCancellationToken()
            invocation = JuliaProgressiveAuthority.start_invocation(
                success_registry,
                _julia_progressive_authority_invocation_config(
                    source_id = "unicode",
                    token = token,
                    now_tick = row["now_tick"],
                    deadline_tick = row["deadline_tick"],
                    remaining_steps = row["remaining_steps"],
                ),
            )
            arguments = _julia_progressive_authority_arguments(
                parser_id = "expr-v1",
                top_rule = "Expr",
                span = Dict{String,Any}(
                    "source_id" => "unicode",
                    "start" => 0,
                    "end" => 1,
                    "provenance" => "safe-point",
                ),
                token = child_token,
                cost = row["cost"],
            )
            if row["accepted"]
                @test JuliaProgressiveAuthority.dispatch(invocation, arguments) === true
            else
                @test _julia_progressive_authority_remember!(
                    observed,
                    () -> JuliaProgressiveAuthority.dispatch(invocation, arguments),
                ) == row["diagnostic"]
            end
            @test JuliaProgressiveAuthority.remaining_steps(invocation) ==
                  row["remaining_after"]
        end

        for row in _julia_progressive_authority_rows("chain_cases")
            candidate = row["candidate"]
            token = JuliaProgressiveAuthority.ProgressiveCancellationToken()
            invocation = JuliaProgressiveAuthority.start_invocation(
                success_registry,
                _julia_progressive_authority_invocation_config(
                    source_id = candidate[3],
                    token = token,
                    now_tick = 1,
                    deadline_tick = 100,
                    remaining_steps = 100,
                    max_depth = row["max_depth"],
                    total_calls = row["total_calls"],
                    max_calls = row["max_calls"],
                    active_chain = [
                        JuliaProgressiveAuthority.ProgressiveChainFrame(
                            parser_id = frame[1],
                            top_rule = frame[2],
                            source_id = frame[3],
                            start = frame[4],
                            stop = frame[5],
                        )
                        for frame in row["active"]
                    ],
                ),
            )
            arguments = _julia_progressive_authority_arguments(
                parser_id = candidate[1],
                top_rule = candidate[2],
                span = Dict{String,Any}(
                    "source_id" => candidate[3],
                    "start" => candidate[4],
                    "end" => candidate[5],
                    "provenance" => "chain-case",
                ),
                token = token,
                cost = 1,
            )
            if row["accepted"]
                @test JuliaProgressiveAuthority.dispatch(invocation, arguments) === true
            else
                @test _julia_progressive_authority_remember!(
                    observed,
                    () -> JuliaProgressiveAuthority.dispatch(invocation, arguments),
                ) == row["diagnostic"]
            end
        end

        for row in _julia_progressive_authority_rows("execution_cases")
            execution_registry =
                _julia_progressive_authority_registry(_ -> row["child_result"])
            token = JuliaProgressiveAuthority.ProgressiveCancellationToken()
            parent_state = _julia_progressive_authority_deepcopy(row["parent_before"])
            invocation = JuliaProgressiveAuthority.start_invocation(
                execution_registry,
                _julia_progressive_authority_invocation_config(
                    source_id = "unicode",
                    token = token,
                    now_tick = 1,
                    deadline_tick = 100,
                    remaining_steps = row["budget_before"],
                ),
            )
            arguments = _julia_progressive_authority_arguments(
                parser_id = "expr-v1",
                top_rule = "Expr",
                span = Dict{String,Any}(
                    "source_id" => "unicode",
                    "start" => 1,
                    "end" => 4,
                    "provenance" => "execution-case",
                ),
                token = token,
                cost = row["child_cost"],
            )
            if row["accepted"]
                @test JuliaProgressiveAuthority.dispatch(invocation, arguments) ==
                      row["child_result"]
            else
                @test _julia_progressive_authority_remember!(
                    observed,
                    () -> JuliaProgressiveAuthority.dispatch(invocation, arguments),
                ) == row["diagnostic"]
            end
            @test parent_state == row["parent_after"]
            @test JuliaProgressiveAuthority.remaining_steps(invocation) ==
                  row["budget_after"]
        end

        seam_token = JuliaProgressiveAuthority.ProgressiveCancellationToken()
        seam_invocation = JuliaProgressiveAuthority.start_invocation(
            success_registry,
            _julia_progressive_authority_invocation_config(
                source_id = "unicode",
                token = seam_token,
                now_tick = 1,
                deadline_tick = 100,
                remaining_steps = 100,
            ),
        )
        valid_span = Dict{String,Any}(
            "source_id" => "unicode",
            "start" => 0,
            "end" => 1,
            "provenance" => "seam",
        )
        seam_calls = [
            _julia_progressive_authority_arguments(
                parser_id = 17,
                top_rule = "Expr",
                span = valid_span,
                token = seam_token,
                cost = 1,
            ),
            _julia_progressive_authority_arguments(
                parser_id = "BAD",
                top_rule = "Expr",
                span = valid_span,
                token = seam_token,
                cost = 1,
            ),
            _julia_progressive_authority_arguments(
                parser_id = "expr-v1",
                top_rule = Any[],
                span = valid_span,
                token = seam_token,
                cost = 1,
            ),
            _julia_progressive_authority_arguments(
                parser_id = "expr-v1",
                top_rule = "bad/rule",
                span = valid_span,
                token = seam_token,
                cost = 1,
            ),
            _julia_progressive_authority_arguments(
                parser_id = "expr-v1",
                top_rule = "Expr",
                span = "copied",
                token = seam_token,
                cost = 1,
            ),
            _julia_progressive_authority_arguments(
                parser_id = "missing-v1",
                top_rule = "Expr",
                span = valid_span,
                token = seam_token,
                cost = 1,
            ),
            _julia_progressive_authority_arguments(
                parser_id = "expr-v1",
                top_rule = "Document",
                span = valid_span,
                token = seam_token,
                cost = 1,
            ),
            _julia_progressive_authority_arguments(
                parser_id = "expr-v1",
                top_rule = "Expr",
                span = valid_span,
                token = seam_token,
                cost = 1,
                transaction_active = true,
            ),
        ]
        for arguments in seam_calls
            _julia_progressive_authority_remember!(
                observed,
                () -> JuliaProgressiveAuthority.dispatch(
                    seam_invocation,
                    arguments,
                ),
            )
        end
        _julia_progressive_authority_remember!(
            observed,
            () -> JuliaProgressiveAuthority.register!(success_registry, "expr-v1"),
        )
        _julia_progressive_authority_remember!(
            observed,
            () -> JuliaProgressiveAuthority.load(success_registry, "expr-v1"),
        )

        diagnostics = Dict{String,Any}(
            row["code"] => row
            for row in _julia_progressive_authority_rows("diagnostics")
        )
        @test Set(keys(observed)) == Set(keys(diagnostics))
        for (code, row) in diagnostics
            record = observed[code]
            for field in row["required_context"]
                @test haskey(record, field)
            end
        end
    end

    @testset "nested dispatch rebases typed values, shares limits, and expires" begin
        retained_view = Ref{Any}(nothing)
        retained_request = Ref{Any}(nothing)
        token = JuliaProgressiveAuthority.ProgressiveCancellationToken()
        nested_registry = _julia_progressive_authority_registry(request -> begin
            retained_view[] = request.source_view
            retained_request[] = request
            text = JuliaProgressiveAuthority.view_text(request.source_view)
            if length(text) > 3
                return JuliaProgressiveAuthority.dispatch_nested(
                    request,
                    _julia_progressive_authority_arguments(
                        parser_id = "expr-v1",
                        top_rule = "Expr",
                        span = Dict{String,Any}(
                            "source_id" => "unicode",
                            "start" => 1,
                            "end" => 4,
                            "provenance" => "nested",
                        ),
                        token = token,
                        cost = 3,
                    ),
                )
            end
            return Dict{String,Any}(
                "text" => text,
                "position" => JuliaProgressiveAuthority.rebase_position(
                    request.source_view,
                    1,
                ),
                "span" => JuliaProgressiveAuthority.rebase_span(
                    request.source_view,
                    Dict{String,Any}(
                        "source_id" => "unicode",
                        "start" => 0,
                        "end" => 2,
                        "provenance" => "child-match",
                    ),
                ),
                "diagnostic" => JuliaProgressiveAuthority.rebase_diagnostic(
                    request.source_view,
                    Dict{String,Any}(
                        "offset" => 1,
                        "span" => Dict{String,Any}(
                            "source_id" => "unicode",
                            "start" => 0,
                            "end" => 2,
                            "provenance" => "child-diagnostic",
                        ),
                    ),
                ),
                "effective" => JuliaProgressiveAuthority.to_json(
                    request.effective,
                ),
            )
        end)
        invocation = JuliaProgressiveAuthority.start_invocation(
            nested_registry,
            _julia_progressive_authority_invocation_config(
                source_id = "unicode",
                token = token,
                now_tick = 1,
                deadline_tick = 100,
                remaining_steps = 20,
                max_depth = 4,
                max_calls = 8,
            ),
        )
        result = JuliaProgressiveAuthority.dispatch(
            invocation,
            _julia_progressive_authority_arguments(
                parser_id = "expr-v1",
                top_rule = "Expr",
                span = Dict{String,Any}(
                    "source_id" => "unicode",
                    "start" => 0,
                    "end" => 5,
                    "provenance" => "outer",
                ),
                token = token,
                cost = 2,
            ),
        )
        @test result["text"] == "é🙂B"
        @test result["position"]["offset"] == 2
        @test result["span"]["start"] == 1
        @test result["span"]["end"] == 3
        @test result["diagnostic"]["offset"] == 2
        @test result["diagnostic"]["span"]["start"] == 1
        @test result["diagnostic"]["span"]["end"] == 3
        @test JuliaProgressiveAuthority.remaining_steps(invocation) == 15
        @test JuliaProgressiveAuthority.total_calls(invocation) == 2
        @test_throws JuliaProgressiveAuthority.ProgressiveSourceViewException begin
            JuliaProgressiveAuthority.view_text(retained_view[])
        end
        @test_throws JuliaProgressiveAuthority.ProgressiveSourceViewException begin
            JuliaProgressiveAuthority.dispatch_nested(
                retained_request[],
                _julia_progressive_authority_arguments(
                    parser_id = "expr-v1",
                    top_rule = "Expr",
                    span = Dict{String,Any}(
                        "source_id" => "unicode",
                        "start" => 2,
                        "end" => 3,
                        "provenance" => "expired-nested-authority",
                    ),
                    token = token,
                    cost = 1,
                ),
            )
        end
    end

    @testset "registry inputs and child results are detached and bounded" begin
        top_rules = ["Expr"]
        capabilities = ["typed-source-location-v1"]
        result_seed = Dict{String,Any}("kind" => "seed", "items" => Any[1])
        entry = JuliaProgressiveAuthority.ProgressiveRegistryEntry(
            parser_id = "expr-v1",
            compiled_authority = _ -> result_seed,
            fingerprint = "sha256:" * repeat("1", 64),
            allowed_top_rules = top_rules,
            capabilities = capabilities,
            ceilings = JuliaProgressiveAuthority.ProgressiveCeilings(
                source_detail = JuliaProgressiveAuthority.ProgressiveSpan,
                policy_modes = ["deterministic"],
                max_steps = 10,
                max_result_nodes = 16,
                max_diagnostic_bytes = 1_024,
            ),
        )
        top_rules[1] = "Mutated"
        capabilities[1] = "mutated"
        registry = JuliaProgressiveAuthority.ProgressiveRegistry(entries = [entry])
        token = JuliaProgressiveAuthority.ProgressiveCancellationToken()
        invocation = JuliaProgressiveAuthority.start_invocation(
            registry,
            _julia_progressive_authority_invocation_config(
                source_id = "unicode",
                token = token,
                now_tick = 1,
                deadline_tick = 100,
                remaining_steps = 10,
            ),
        )
        detached = JuliaProgressiveAuthority.dispatch(
            invocation,
            _julia_progressive_authority_arguments(
                parser_id = "expr-v1",
                top_rule = "Expr",
                span = Dict{String,Any}(
                    "source_id" => "unicode",
                    "start" => 0,
                    "end" => 1,
                    "provenance" => "detachment",
                ),
                token = token,
                cost = 1,
                caller_capabilities = ["typed-source-location-v1"],
                caller_ceilings = JuliaProgressiveAuthority.ProgressiveCeilings(
                    source_detail = JuliaProgressiveAuthority.ProgressiveSpan,
                    policy_modes = ["deterministic"],
                    max_steps = 10,
                    max_result_nodes = 16,
                    max_diagnostic_bytes = 1_024,
                ),
            ),
        )
        result_seed["kind"] = "mutated"
        push!(result_seed["items"], 2)
        @test detached == Dict{String,Any}("kind" => "seed", "items" => Any[1])

        oversized_registry = _julia_progressive_authority_registry(
            _ -> Any[1, 2],
        )
        oversized_token = JuliaProgressiveAuthority.ProgressiveCancellationToken()
        oversized_invocation = JuliaProgressiveAuthority.start_invocation(
            oversized_registry,
            _julia_progressive_authority_invocation_config(
                source_id = "unicode",
                token = oversized_token,
                now_tick = 1,
                deadline_tick = 100,
                remaining_steps = 10,
            ),
        )
        oversized_error = _julia_progressive_authority_capture(
            () -> JuliaProgressiveAuthority.dispatch(
                oversized_invocation,
                _julia_progressive_authority_arguments(
                    parser_id = "expr-v1",
                    top_rule = "Expr",
                    span = Dict{String,Any}(
                        "source_id" => "unicode",
                        "start" => 0,
                        "end" => 1,
                        "provenance" => "oversized",
                    ),
                    token = oversized_token,
                    cost = 1,
                    caller_ceilings = JuliaProgressiveAuthority.ProgressiveCeilings(
                        source_detail = JuliaProgressiveAuthority.ProgressiveSpan,
                        policy_modes = ["deterministic", "fail-only"],
                        max_steps = 10,
                        max_result_nodes = 2,
                        max_diagnostic_bytes = 1_024,
                    ),
                ),
            ),
        )
        @test oversized_error isa
              JuliaProgressiveAuthority.ProgressiveDispatchException
        @test JuliaProgressiveAuthority.diagnostic_code(oversized_error) ==
              "progressive_result_not_detached"

        diagnostic_registry = _julia_progressive_authority_registry(
            _ -> error("éé"),
        )
        diagnostic_token = JuliaProgressiveAuthority.ProgressiveCancellationToken()
        diagnostic_invocation = JuliaProgressiveAuthority.start_invocation(
            diagnostic_registry,
            _julia_progressive_authority_invocation_config(
                source_id = "unicode",
                token = diagnostic_token,
                now_tick = 1,
                deadline_tick = 100,
                remaining_steps = 10,
            ),
        )
        diagnostic_error = _julia_progressive_authority_capture(
            () -> JuliaProgressiveAuthority.dispatch(
                diagnostic_invocation,
                _julia_progressive_authority_arguments(
                    parser_id = "expr-v1",
                    top_rule = "Expr",
                    span = Dict{String,Any}(
                        "source_id" => "unicode",
                        "start" => 0,
                        "end" => 1,
                        "provenance" => "diagnostic",
                    ),
                    token = diagnostic_token,
                    cost = 1,
                    caller_ceilings = JuliaProgressiveAuthority.ProgressiveCeilings(
                        source_detail = JuliaProgressiveAuthority.ProgressiveSpan,
                        policy_modes = ["deterministic", "fail-only"],
                        max_steps = 10,
                        max_result_nodes = 16,
                        max_diagnostic_bytes = 1,
                    ),
                ),
            ),
        )
        @test diagnostic_error isa
              JuliaProgressiveAuthority.ProgressiveDispatchException
        @test JuliaProgressiveAuthority.diagnostic_code(diagnostic_error) ==
              "progressive_child_failed"
        @test JuliaProgressiveAuthority.to_json(diagnostic_error)[
            "child_diagnostic"
        ] == "?"

        cycle = Dict{String,Any}()
        cycle["child"] = cycle
        cyclic_registry = _julia_progressive_authority_registry(_ -> cycle)
        cyclic_token = JuliaProgressiveAuthority.ProgressiveCancellationToken()
        cyclic_invocation = JuliaProgressiveAuthority.start_invocation(
            cyclic_registry,
            _julia_progressive_authority_invocation_config(
                source_id = "unicode",
                token = cyclic_token,
                now_tick = 1,
                deadline_tick = 100,
                remaining_steps = 10,
            ),
        )
        cyclic_error = _julia_progressive_authority_capture(
            () -> JuliaProgressiveAuthority.dispatch(
                cyclic_invocation,
                _julia_progressive_authority_arguments(
                    parser_id = "expr-v1",
                    top_rule = "Expr",
                    span = Dict{String,Any}(
                        "source_id" => "unicode",
                        "start" => 0,
                        "end" => 1,
                        "provenance" => "cyclic",
                    ),
                    token = cyclic_token,
                    cost = 1,
                ),
            ),
        )
        @test cyclic_error isa JuliaProgressiveAuthority.ProgressiveDispatchException
        @test JuliaProgressiveAuthority.diagnostic_code(cyclic_error) ==
              "progressive_result_not_detached"

        nonfinite_registry = _julia_progressive_authority_registry(_ -> Inf)
        nonfinite_token = JuliaProgressiveAuthority.ProgressiveCancellationToken()
        nonfinite_invocation = JuliaProgressiveAuthority.start_invocation(
            nonfinite_registry,
            _julia_progressive_authority_invocation_config(
                source_id = "unicode",
                token = nonfinite_token,
                now_tick = 1,
                deadline_tick = 100,
                remaining_steps = 10,
            ),
        )
        nonfinite_error = _julia_progressive_authority_capture(
            () -> JuliaProgressiveAuthority.dispatch(
                nonfinite_invocation,
                _julia_progressive_authority_arguments(
                    parser_id = "expr-v1",
                    top_rule = "Expr",
                    span = Dict{String,Any}(
                        "source_id" => "unicode",
                        "start" => 0,
                        "end" => 1,
                        "provenance" => "nonfinite",
                    ),
                    token = nonfinite_token,
                    cost = 1,
                ),
            ),
        )
        @test nonfinite_error isa
              JuliaProgressiveAuthority.ProgressiveDispatchException
        @test JuliaProgressiveAuthority.diagnostic_code(nonfinite_error) ==
              "progressive_result_not_detached"
    end

    @testset "authority remains private, dormant, and carrier-scoped" begin
        @test :BoundedChildParseAuthority ∉ names(LinkedSpecJulia)
        @test !isfile(
            joinpath(
                JULIA_PROGRESSIVE_AUTHORITY_ROOT,
                "julia",
                "test",
                "progressive_span_dispatch_authority_test.jl",
            ),
        )
        ci_driver = read(
            joinpath(JULIA_PROGRESSIVE_AUTHORITY_ROOT, "tools", "run_ci_local.sh"),
            String,
        )
        @test !occursin("progressive_span_dispatch_authority_test", ci_driver)
        interpreter = read(
            joinpath(
                JULIA_PROGRESSIVE_AUTHORITY_ROOT,
                "julia",
                "src",
                "runtime",
                "Interpreter.jl",
            ),
            String,
        )
        @test !occursin("dispatch_bounded_child_parse", interpreter)
        @test occursin("ProgressiveExecutionSeed", interpreter)
    end
end
