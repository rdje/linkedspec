# FUTURE-PARITY-BACKLOG.10.9.5.1 — public Julia decoded MCP dispatch proof.

const _MCP_TEST_SERVER_NAME = "linkedspec-semantic-julia"
function _mcp_test_graph_index(detail)
    return semantic_index(
        read(
            joinpath(
                REPO_ROOT,
                "capability_conformance",
                "semantic_introspection",
                "graph.spec",
            ),
            String,
        );
        logical_name = "graph.spec",
        source_detail_ceiling = detail,
    )
end

const _MCP_TEST_GRAPH_INDEX = _mcp_test_graph_index(SemanticSourceTextDetail)

mutable struct _McpTestClock
    value::Int
end

function _mcp_test_error(call, code)
    try
        call()
    catch error
        @test error isa McpServerError
        @test error.code == code
        return error
    end
    @test false
    return nothing
end

_mcp_test_authorization(value = "principal") = collect(codeunits(value))
_mcp_test_frame(id) = LinkedSpecJulia._mcp_frame(id)
_mcp_test_clone(value) = LinkedSpecJulia._mcp_copy_json(value)
_mcp_test_canonical(value) = LinkedSpecJulia._mcp_canonical_json(value)

function _mcp_test_with_handle!(request, handle)
    request["params"]["arguments"]["handle"] = handle
    return request
end

_mcp_test_request_arguments(request) = request["params"]["arguments"]["request"]

function _mcp_test_with_julia_identity!(response)
    response["result"]["_meta"]["io.modelcontextprotocol/serverInfo"]["name"] =
        _MCP_TEST_SERVER_NAME
    return response
end

function _mcp_test_server(entropy_byte::UInt8; clock = _McpTestClock(0))
    return LinkedSpecJulia._mcp_test_server(
        entropy = () -> fill(entropy_byte, 32),
        now_ms = () -> clock.value,
    )
end

@testset "Julia native decoded MCP server" begin
    @testset "public static dispatch matches every owned classification" begin
        server = McpServer()
        for (request_id, response_id, julia_identity) in (
            ("discover_request", "discover_response_julia", false),
            ("tools_list_request", "tools_list_response_perl", true),
            ("unsupported_version_request", "unsupported_version_response", false),
            ("missing_metadata_request", "missing_metadata_response", false),
            ("legacy_initialize_request", "legacy_initialize_response", false),
            ("unknown_method_request", "unknown_method_response", false),
            ("unknown_tool_request", "unknown_tool_response", false),
            ("malformed_arguments_request", "malformed_arguments_response", false),
        )
            request = _mcp_test_frame(request_id)
            before = _mcp_test_canonical(request)
            expected = _mcp_test_frame(response_id)
            julia_identity && _mcp_test_with_julia_identity!(expected)
            @test dispatch_mcp(server, request, _mcp_test_authorization("static-principal")) ==
                  expected
            @test _mcp_test_canonical(request) == before
        end
        @test dispatch_mcp(
            server,
            _mcp_test_frame("legacy_initialized_notification"),
            _mcp_test_authorization("static-principal"),
        ) === nothing
        @test dispatch_mcp(
            server,
            Dict{String,Any}(
                "jsonrpc" => "2.0",
                "method" => "notifications/host_private",
            ),
            _mcp_test_authorization("static-principal"),
        ) === nothing
    end

    @testset "registration preserves native identity and lowers policy only" begin
        capability_calls = Ref(0)
        query_calls = Ref(0)
        entropy_byte = Ref(UInt8(0x42))
        server = LinkedSpecJulia._mcp_test_server(
            entropy = () -> begin
                bytes = fill(entropy_byte[], 32)
                entropy_byte[] += UInt8(1)
                bytes
            end,
            now_ms = () -> 1_000,
            capabilities_of = index -> begin
                @test index === _MCP_TEST_GRAPH_INDEX
                capability_calls[] += 1
                to_json(semantic_capabilities(index))
            end,
            query_index = (index, request) -> begin
                @test index === _MCP_TEST_GRAPH_INDEX
                query_calls[] += 1
                to_json(semantic_query_neutral(index, request))
            end,
        )
        handle = register_index!(
            server,
            _MCP_TEST_GRAPH_INDEX,
            _mcp_test_authorization("native-principal"),
        )
        @test occursin(r"^[A-Za-z0-9_-]{43}$", handle)
        @test capability_calls[] == 1

        capabilities = _mcp_test_with_handle!(
            _mcp_test_frame("capabilities_call_request"),
            handle,
        )
        capabilities_before = _mcp_test_canonical(capabilities)
        @test dispatch_mcp(
            server,
            capabilities,
            _mcp_test_authorization("native-principal"),
        ) == _mcp_test_with_julia_identity!(
            _mcp_test_frame("capabilities_call_response"),
        )
        @test capability_calls[] == 2
        @test _mcp_test_canonical(capabilities) == capabilities_before

        query = _mcp_test_with_handle!(_mcp_test_frame("query_call_request"), handle)
        query_before = _mcp_test_canonical(query)
        @test dispatch_mcp(server, query, _mcp_test_authorization("native-principal")) ==
              _mcp_test_with_julia_identity!(_mcp_test_frame("query_call_response"))
        @test query_calls[] == 1
        @test _mcp_test_canonical(query) == query_before

        semantic_error = _mcp_test_with_handle!(
            _mcp_test_frame("semantic_ok_false_request"),
            handle,
        )
        @test dispatch_mcp(
            server,
            semantic_error,
            _mcp_test_authorization("native-principal"),
        ) == _mcp_test_with_julia_identity!(
            _mcp_test_frame("semantic_ok_false_response"),
        )
        @test query_calls[] == 2

        restricted = register_index!(
            server,
            _MCP_TEST_GRAPH_INDEX,
            _mcp_test_authorization("restricted-principal");
            options = McpRegistrationOptions(
                policy = McpDeploymentPolicy(
                    source_detail_ceiling = SemanticSourceIdentityDetail,
                    page_max = 50,
                    budget_maxima = McpBudgetLimits(
                        max_records = 100,
                        max_relations = 200,
                        max_depth = 2,
                    ),
                ),
            ),
        )
        @test dispatch_mcp(
            server,
            _mcp_test_with_handle!(
                _mcp_test_frame("restricted_capabilities_request"),
                restricted,
            ),
            _mcp_test_authorization("restricted-principal"),
        ) == _mcp_test_with_julia_identity!(
            _mcp_test_frame("restricted_capabilities_response"),
        )
        before_denied = query_calls[]
        @test dispatch_mcp(
            server,
            _mcp_test_with_handle!(_mcp_test_frame("policy_denied_request"), restricted),
            _mcp_test_authorization("restricted-principal"),
        ) == _mcp_test_with_julia_identity!(_mcp_test_frame("policy_denied_response"))
        @test query_calls[] == before_denied

        allowed = _mcp_test_with_handle!(_mcp_test_frame("query_call_request"), restricted)
        allowed_request = _mcp_test_request_arguments(allowed)
        allowed_request["page"]["limit"] = 50
        allowed_request["budget"] = Dict{String,Any}(
            "max_records" => 100,
            "max_relations" => 200,
            "max_depth" => 2,
        )
        denied_cases = Dict{String,Any}[]
        source_denied = _mcp_test_clone(allowed)
        _mcp_test_request_arguments(source_denied)["source"]["detail"] = "span"
        push!(denied_cases, source_denied)
        digest_denied = _mcp_test_clone(allowed)
        _mcp_test_request_arguments(digest_denied)["source"]["include_content_digest"] = true
        push!(denied_cases, digest_denied)
        page_denied = _mcp_test_clone(allowed)
        _mcp_test_request_arguments(page_denied)["page"]["limit"] = 51
        push!(denied_cases, page_denied)
        for (name, value) in (
            ("max_records", 101),
            ("max_relations", 201),
            ("max_depth", 3),
        )
            budget_denied = _mcp_test_clone(allowed)
            _mcp_test_request_arguments(budget_denied)["budget"][name] = value
            push!(denied_cases, budget_denied)
        end
        policy_for_eight = _mcp_test_with_julia_identity!(
            _mcp_test_frame("policy_denied_response"),
        )
        policy_for_eight["id"] = 8
        for denied_case in denied_cases
            before_policy_denial = query_calls[]
            @test dispatch_mcp(
                server,
                denied_case,
                _mcp_test_authorization("restricted-principal"),
            ) == policy_for_eight
            @test query_calls[] == before_policy_denial
        end

        invalid_policies = (
            McpDeploymentPolicy(page_max = 1_001),
            McpDeploymentPolicy(
                budget_maxima = McpBudgetLimits(
                    max_records = 10_001,
                    max_relations = 2_000,
                    max_depth = 4,
                ),
            ),
            McpDeploymentPolicy(
                budget_maxima = McpBudgetLimits(
                    max_records = -1,
                    max_relations = 1,
                    max_depth = 1,
                ),
            ),
        )
        for policy in invalid_policies
            _mcp_test_error("linkedspec_mcp_invalid_policy") do
                register_index!(
                    server,
                    _MCP_TEST_GRAPH_INDEX,
                    _mcp_test_authorization("invalid-policy-principal");
                    options = McpRegistrationOptions(policy = policy),
                )
            end
        end
    end

    @testset "omitted and partial overlays preserve native diagnostics" begin
        identity_index = _mcp_test_graph_index(SemanticSourceIdentityDetail)
        query_calls = Ref(0)
        entropy_byte = Ref(UInt8(0x52))
        server = LinkedSpecJulia._mcp_test_server(
            entropy = () -> begin
                bytes = fill(entropy_byte[], 32)
                entropy_byte[] += UInt8(1)
                bytes
            end,
            now_ms = () -> 1_000,
            capabilities_of = index -> to_json(semantic_capabilities(index)),
            query_index = (index, request) -> begin
                query_calls[] += 1
                to_json(semantic_query_neutral(index, request))
            end,
        )
        default_handle = register_index!(
            server,
            identity_index,
            _mcp_test_authorization("default-policy-principal"),
        )
        source_request = _mcp_test_with_handle!(
            _mcp_test_frame("query_call_request"),
            default_handle,
        )
        _mcp_test_request_arguments(source_request)["source"]["detail"] = "span"
        source_response = dispatch_mcp(
            server,
            source_request,
            _mcp_test_authorization("default-policy-principal"),
        )
        @test source_response["result"]["structuredContent"]["diagnostics"][1]["code"] ==
              "semantic_query_source_detail_forbidden"
        @test query_calls[] == 1

        unsupported = _mcp_test_with_handle!(
            _mcp_test_frame("query_call_request"),
            default_handle,
        )
        _mcp_test_request_arguments(unsupported)["contract"] =
            "linkedspec-semantic-query-v2"
        unsupported_response = dispatch_mcp(
            server,
            unsupported,
            _mcp_test_authorization("default-policy-principal"),
        )
        @test unsupported_response["result"]["structuredContent"]["diagnostics"][1]["code"] ==
              "semantic_query_contract_unsupported"
        @test query_calls[] == 2

        partial_handle = register_index!(
            server,
            identity_index,
            _mcp_test_authorization("partial-policy-principal");
            options = McpRegistrationOptions(
                policy = McpDeploymentPolicy(page_max = 50),
            ),
        )
        partial_request = _mcp_test_with_handle!(
            _mcp_test_frame("query_call_request"),
            partial_handle,
        )
        partial = _mcp_test_request_arguments(partial_request)
        partial["page"]["limit"] = 50
        partial["source"]["detail"] = "span"
        partial_response = dispatch_mcp(
            server,
            partial_request,
            _mcp_test_authorization("partial-policy-principal"),
        )
        @test partial_response["result"]["structuredContent"]["diagnostics"][1]["code"] ==
              "semantic_query_source_detail_forbidden"
        @test query_calls[] == 3
    end

    @testset "unavailable states, validation, capacity, and shutdown are safe" begin
        expected_unavailable = _mcp_test_with_julia_identity!(
            _mcp_test_frame("handle_unavailable_response"),
        )
        unknown = _mcp_test_server(UInt8(0x44))
        @test dispatch_mcp(
            unknown,
            _mcp_test_frame("handle_unavailable_request"),
            _mcp_test_authorization(),
        ) == expected_unavailable

        unauthorized = _mcp_test_server(UInt8(0x45))
        unauthorized_handle = register_index!(
            unauthorized,
            _MCP_TEST_GRAPH_INDEX,
            _mcp_test_authorization(),
        )
        @test dispatch_mcp(
            unauthorized,
            _mcp_test_with_handle!(
                _mcp_test_frame("handle_unavailable_request"),
                unauthorized_handle,
            ),
            _mcp_test_authorization("wrong"),
        ) == expected_unavailable

        clock = _McpTestClock(1_000)
        expired = _mcp_test_server(UInt8(0x46); clock)
        expired_handle = register_index!(
            expired,
            _MCP_TEST_GRAPH_INDEX,
            _mcp_test_authorization();
            options = McpRegistrationOptions(lifetime_ms = 1),
        )
        clock.value = 1_001
        @test dispatch_mcp(
            expired,
            _mcp_test_with_handle!(
                _mcp_test_frame("handle_unavailable_request"),
                expired_handle,
            ),
            _mcp_test_authorization(),
        ) == expected_unavailable

        revoked = _mcp_test_server(UInt8(0x47))
        revoked_handle = register_index!(
            revoked,
            _MCP_TEST_GRAPH_INDEX,
            _mcp_test_authorization(),
        )
        revoke_handle!(revoked, revoked_handle)
        revoke_handle!(revoked, revoked_handle)
        @test dispatch_mcp(
            revoked,
            _mcp_test_with_handle!(
                _mcp_test_frame("handle_unavailable_request"),
                revoked_handle,
            ),
            _mcp_test_authorization(),
        ) == expected_unavailable
        _mcp_test_error("linkedspec_mcp_invalid_handle") do
            revoke_handle!(revoked, "invalid")
        end

        for authorization in (UInt8[], fill(UInt8(0x61), 4_097), [1])
            _mcp_test_error("linkedspec_mcp_invalid_authorization") do
                register_index!(revoked, _MCP_TEST_GRAPH_INDEX, authorization)
            end
        end
        for lifetime in (0, 86_400_001)
            _mcp_test_error("linkedspec_mcp_invalid_registration") do
                register_index!(
                    revoked,
                    _MCP_TEST_GRAPH_INDEX,
                    _mcp_test_authorization();
                    options = McpRegistrationOptions(lifetime_ms = lifetime),
                )
            end
        end

        capacity_clock = _McpTestClock(2_000)
        entropy_byte = Ref(UInt8(0x48))
        capacity = LinkedSpecJulia._mcp_test_server(
            entropy = () -> begin
                bytes = fill(entropy_byte[], 32)
                entropy_byte[] += UInt8(1)
                bytes
            end,
            now_ms = () -> capacity_clock.value,
            maximum_handles = 1,
        )
        register_index!(
            capacity,
            _MCP_TEST_GRAPH_INDEX,
            _mcp_test_authorization();
            options = McpRegistrationOptions(lifetime_ms = 1),
        )
        _mcp_test_error("linkedspec_mcp_registry_full") do
            register_index!(capacity, _MCP_TEST_GRAPH_INDEX, _mcp_test_authorization())
        end
        capacity_clock.value = 2_001
        @test occursin(
            r"^[A-Za-z0-9_-]{43}$",
            register_index!(capacity, _MCP_TEST_GRAPH_INDEX, _mcp_test_authorization()),
        )
        @test LinkedSpecJulia._mcp_registered_handles(capacity) == 1
        shutdown_mcp!(capacity)
        shutdown_mcp!(capacity)
        @test LinkedSpecJulia._mcp_registered_handles(capacity) == 0
        @test dispatch_mcp(
            capacity,
            _mcp_test_frame("discover_request"),
            _mcp_test_authorization(),
        )["error"]["code"] == -32603
        _mcp_test_error("linkedspec_mcp_server_shutdown") do
            register_index!(capacity, _MCP_TEST_GRAPH_INDEX, _mcp_test_authorization())
        end
    end

    @testset "entropy and clock failures are bounded and sanitized" begin
        short_entropy = LinkedSpecJulia._mcp_test_server(
            entropy = () -> fill(UInt8(0x49), 31),
            now_ms = () -> 0,
        )
        _mcp_test_error("linkedspec_mcp_entropy_failure") do
            register_index!(short_entropy, _MCP_TEST_GRAPH_INDEX, _mcp_test_authorization())
        end

        bad_clock = LinkedSpecJulia._mcp_test_server(
            entropy = () -> fill(UInt8(0x4a), 32),
            now_ms = () -> error("host path /private/secret"),
        )
        clock_error = _mcp_test_error("linkedspec_mcp_clock_failure") do
            register_index!(bad_clock, _MCP_TEST_GRAPH_INDEX, _mcp_test_authorization())
        end
        @test !occursin("private", sprint(showerror, clock_error))

        collision = LinkedSpecJulia._mcp_test_server(
            entropy = () -> fill(UInt8(0x4b), 32),
            now_ms = () -> 0,
            maximum_handles = 2,
            handle_attempts = 2,
        )
        register_index!(collision, _MCP_TEST_GRAPH_INDEX, _mcp_test_authorization())
        _mcp_test_error("linkedspec_mcp_entropy_failure") do
            register_index!(collision, _MCP_TEST_GRAPH_INDEX, _mcp_test_authorization())
        end

        overflow_clock = LinkedSpecJulia._mcp_test_server(
            entropy = () -> fill(UInt8(0x4d), 32),
            now_ms = () -> typemax(Int),
        )
        _mcp_test_error("linkedspec_mcp_clock_failure") do
            register_index!(overflow_clock, _MCP_TEST_GRAPH_INDEX, _mcp_test_authorization())
        end

        invalid_index = LinkedSpecJulia._mcp_test_server(
            entropy = () -> fill(UInt8(0x4e), 32),
            now_ms = () -> 0,
            capabilities_of = _ -> Dict{String,Any}("host_private" => true),
        )
        _mcp_test_error("linkedspec_mcp_invalid_index") do
            register_index!(invalid_index, _MCP_TEST_GRAPH_INDEX, _mcp_test_authorization())
        end

        authorization = _mcp_test_authorization("copied-principal")
        copied_authorization = _mcp_test_server(UInt8(0x4f))
        copied_handle = register_index!(
            copied_authorization,
            _MCP_TEST_GRAPH_INDEX,
            authorization,
        )
        fill!(authorization, UInt8(0))
        @test dispatch_mcp(
            copied_authorization,
            _mcp_test_with_handle!(
                _mcp_test_frame("capabilities_call_request"),
                copied_handle,
            ),
            _mcp_test_authorization("copied-principal"),
        ) == _mcp_test_with_julia_identity!(
            _mcp_test_frame("capabilities_call_response"),
        )

        @test LinkedSpecJulia._mcp_fixed_digest_equal(zeros(UInt8, 32), zeros(UInt8, 32))
        @test !LinkedSpecJulia._mcp_fixed_digest_equal(zeros(UInt8, 32), ones(UInt8, 32))
        production = McpServer()
        @test occursin(
            r"^[A-Za-z0-9_-]{43}$",
            register_index!(production, _MCP_TEST_GRAPH_INDEX, _mcp_test_authorization()),
        )
    end

    @testset "native failures are sanitized and cancellation suppresses preparation" begin
        mode = Ref(:normal)
        server_ref = Ref{McpServer}()
        server = LinkedSpecJulia._mcp_test_server(
            entropy = () -> fill(UInt8(0x4c), 32),
            now_ms = () -> 0,
            capabilities_of = index -> begin
                mode[] == :throw && error("host secret /private/path")
                mode[] == :invalid && return Dict{String,Any}("host_private" => true)
                if mode[] == :cancel
                    cancel = _mcp_test_frame("cancelled_notification")
                    cancel["params"]["requestId"] = 7
                    dispatch_mcp(server_ref[], cancel, _mcp_test_authorization())
                end
                to_json(semantic_capabilities(index))
            end,
        )
        server_ref[] = server
        handle = register_index!(server, _MCP_TEST_GRAPH_INDEX, _mcp_test_authorization())
        request = _mcp_test_with_handle!(
            _mcp_test_frame("capabilities_call_request"),
            handle,
        )
        internal = _mcp_test_frame("sanitized_internal_error_response")
        internal["id"] = 7

        mode[] = :throw
        thrown = dispatch_mcp(server, request, _mcp_test_authorization())
        @test thrown == internal
        @test !occursin("host secret", _mcp_test_canonical(thrown))
        @test !occursin("private/path", _mcp_test_canonical(thrown))

        mode[] = :invalid
        @test dispatch_mcp(server, request, _mcp_test_authorization()) == internal

        mode[] = :cancel
        @test dispatch_mcp(server, request, _mcp_test_authorization()) === nothing
        @test LinkedSpecJulia._mcp_active_requests(server) == 0

        mode[] = :normal
        completed = dispatch_mcp(server, request, _mcp_test_authorization())
        @test completed == _mcp_test_with_julia_identity!(
            _mcp_test_frame("capabilities_call_response"),
        )
        late_cancel = _mcp_test_frame("cancelled_notification")
        late_cancel["params"]["requestId"] = 7
        @test dispatch_mcp(server, late_cancel, _mcp_test_authorization()) === nothing
        @test completed == _mcp_test_with_julia_identity!(
            _mcp_test_frame("capabilities_call_response"),
        )
    end

    @testset "public server is opaque and production authority remains narrow" begin
        server = McpServer()
        @test isempty(propertynames(server))
        @test repr(server) == "McpServer(stopped=false)"
        @test_throws ArgumentError server.entries

        exported = Set(names(LinkedSpecJulia))
        for name in (
            :McpBudgetLimits,
            :McpDeploymentPolicy,
            :McpRegistrationOptions,
            :McpServer,
            :McpServerError,
            :register_index!,
            :revoke_handle!,
            :dispatch_mcp,
            :shutdown_mcp!,
        )
            @test name in exported
        end
        @test !(:_mcp_test_server in exported)

        runtime = read(
            joinpath(REPO_ROOT, "julia", "src", "mcp", "McpContractRuntime.jl"),
            String,
        )
        production = runtime * "\n" * read(
            joinpath(REPO_ROOT, "julia", "src", "mcp", "McpServer.jl"),
            String,
        )
        for forbidden in (
            "open(",
            "rm(",
            "mkpath(",
            "ENV[",
            "run(",
            "Cmd(",
            "Sockets",
            "HTTP",
            "parse_spec(",
            "compile_spec(",
            "load_spec(",
            "LinkedSpecRuntimeEngine",
            "LINKEDSPEC_TRACE_LEVEL",
            "emit_julia_source",
        )
            @test !occursin(forbidden, production)
        end
        primary = read(joinpath(REPO_ROOT, "julia", "bin", "linkedspec_julia.jl"), String)
        @test !occursin("McpServer", primary)
        @test !occursin("dispatch_mcp", primary)
        project = read(joinpath(REPO_ROOT, "julia", "Project.toml"), String)
        for dependency in ("Base64", "JSON3", "Random", "SHA")
            @test occursin(Regex("^" * dependency * " = ", "m"), project)
        end
    end
end
