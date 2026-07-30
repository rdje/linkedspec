# FUTURE-PARITY-BACKLOG.10.9.5.1 — generated Julia MCP binding/runtime proof.

@testset "Julia MCP generated binding and frozen runtime" begin
    @testset "embedded bundle is digest-verified and clone-isolated" begin
        first = LinkedSpecJulia._mcp_contract()
        @test first["protocol_version"] == "2026-07-28"
        first["protocol_version"] = "mutated"
        @test LinkedSpecJulia._mcp_contract()["protocol_version"] == "2026-07-28"

        discover = LinkedSpecJulia._mcp_frame("discover_request")
        @test discover !== nothing
        @test LinkedSpecJulia._mcp_validate_frame(discover)

        generated = read(joinpath(REPO_ROOT, "julia", "src", "mcp", "McpContract.jl"), String)
        @test occursin("_MCP_BUNDLE_BASE64", generated)
        @test !occursin("canonical_frames", generated)
        @test !occursin("protocol_version", generated)
    end

    @testset "frozen schema profile checks patterns and object closure" begin
        @test LinkedSpecJulia._mcp_validate_named("handle", repeat("A", 43))
        @test !LinkedSpecJulia._mcp_validate_named("handle", repeat("A", 42))
        discover = LinkedSpecJulia._mcp_frame("discover_request")
        @test LinkedSpecJulia._mcp_validate_named("discoverRequest", discover)
        discover["extra"] = true
        @test !LinkedSpecJulia._mcp_validate_named("discoverRequest", discover)
    end

    @testset "top-level schema classifies the canonical corpus exactly" begin
        accepted = (
            "discover_request",
            "discover_response_perl",
            "discover_response_rust",
            "discover_response_dart",
            "discover_response_julia",
            "discover_response_lua",
            "tools_list_request",
            "tools_list_response_perl",
            "capabilities_call_request",
            "capabilities_call_response",
            "query_call_request",
            "query_call_response",
            "semantic_ok_false_request",
            "semantic_ok_false_response",
            "restricted_capabilities_request",
            "restricted_capabilities_response",
            "handle_unavailable_request",
            "handle_unavailable_response",
            "policy_denied_request",
            "policy_denied_response",
            "cancelled_notification",
            "unsupported_version_response",
            "missing_metadata_response",
            "legacy_initialize_response",
            "unknown_method_response",
            "unknown_tool_response",
            "malformed_arguments_response",
            "sanitized_internal_error_response",
        )
        rejected = (
            "unsupported_version_request",
            "missing_metadata_request",
            "legacy_initialize_request",
            "legacy_initialized_notification",
            "unknown_method_request",
            "unknown_tool_request",
            "malformed_arguments_request",
        )
        for id in accepted
            @test LinkedSpecJulia._mcp_validate_frame(LinkedSpecJulia._mcp_frame(id))
        end
        for id in rejected
            @test !LinkedSpecJulia._mcp_validate_frame(LinkedSpecJulia._mcp_frame(id))
        end
    end

    @testset "canonical JSON sorts recursively without normalizing text" begin
        value = Dict{String,Any}(
            "z" => 1,
            "a" => Dict{String,Any}(
                "β" => "e\u0301",
                "a" => Any[Dict{String,Any}("z" => false, "a" => true)],
            ),
        )
        @test LinkedSpecJulia._mcp_canonical_json(value) ==
              "{\"a\":{\"a\":[{\"a\":true,\"z\":false}],\"β\":\"é\"},\"z\":1}"
        @test_throws LinkedSpecJulia._McpContractError LinkedSpecJulia._mcp_canonical_json(
            Dict{String,Any}("bad" => NaN),
        )
    end
end
