# FUTURE-PARITY-BACKLOG.10.9.5.3 — exact twelve-role Julia MCP admission.

import JSON3

const _MCP_ADMISSION_ROLE_ORDER = [
    "contract_inventory",
    "canonical_static_dispatch",
    "native_capabilities_identity",
    "native_query_identity",
    "raw_input_outcomes",
    "lifecycle_outcomes",
    "handle_state_indistinguishability",
    "policy_overlay",
    "cancellation_emission",
    "shutdown_and_io",
    "hostile_output_and_log_privacy",
    "authority_surface_fences",
]

const _MCP_ADMISSION_RAW_IDS = [
    "invalid_utf8",
    "utf8_bom",
    "malformed_json",
    "duplicate_key",
    "overlong_line",
    "json_batch",
    "non_object",
    "invalid_boolean_id",
    "nesting_depth_65",
    "valid_crlf_discovery",
]

const _MCP_ADMISSION_LIFECYCLE_IDS = [
    "ready_at_stream_loop_start",
    "cancel_before_response_emission",
    "cancel_unknown_request",
    "cancel_after_sync_completion",
    "legacy_initialized_notification",
    "stdout_discipline",
    "stderr_default",
    "registry_capacity",
    "graceful_eof",
    "unexpected_io_failure",
]

const _MCP_ADMISSION_HANDLE_STATES = ["unknown", "expired", "revoked", "unauthorized"]
const _MCP_ADMISSION_POLICY_IDS = [
    "default_capabilities_identity",
    "restricted_capabilities_projection",
    "allowed_query_identity",
    "above_policy_pre_dispatch_denial",
]
const _MCP_ADMISSION_SERVER_NAME = "linkedspec-semantic-julia"
const _MCP_ADMISSION_IO_LOG = "linkedspec_mcp_io_failure\n"
const _MCP_ADMISSION_CORPUS = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "mcp_semantic_transport",
            "corpus.json",
        ),
        String,
    ),
    Dict{String,Any},
)
const _MCP_ADMISSION_FRAME_LINES = readlines(
    joinpath(
        REPO_ROOT,
        "capability_conformance",
        "mcp_semantic_transport",
        "canonical_frames.jsonl",
    ),
)
const _MCP_ADMISSION_GRAPH_INDEX = semantic_index(
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
    source_detail_ceiling = SemanticSourceTextDetail,
)

struct _McpAdmissionFailingInput <: IO end

Base.readbytes!(::_McpAdmissionFailingInput, ::AbstractArray{UInt8}, requested = 0) =
    error("private=/private/secret handle=opaque auth=principal request=hidden")
Base.bytesavailable(::_McpAdmissionFailingInput) = 0
Base.isopen(::_McpAdmissionFailingInput) = true

mutable struct _McpAdmissionFailingAfter <: IO
    bytes::Vector{UInt8}
    offset::Int
end

function Base.readbytes!(
    input::_McpAdmissionFailingAfter,
    target::AbstractArray{UInt8},
    requested = length(target),
)
    input.offset > length(input.bytes) && error("private later input failure")
    count = min(Int(requested), length(target), length(input.bytes) - input.offset + 1)
    copyto!(target, 1, input.bytes, input.offset, count)
    input.offset += count
    return count
end

Base.bytesavailable(input::_McpAdmissionFailingAfter) =
    max(0, length(input.bytes) - input.offset + 1)
Base.isopen(::_McpAdmissionFailingAfter) = true

mutable struct _McpAdmissionOutput <: IO
    bytes::Vector{UInt8}
    fail_write::Bool
    open::Bool
end

_McpAdmissionOutput(; fail_write = false) =
    _McpAdmissionOutput(UInt8[], fail_write, true)

function Base.write(output::_McpAdmissionOutput, bytes::StridedVector{UInt8})
    output.open || error("private closed output")
    output.fail_write && error("private output path, handle, response, and principal")
    append!(output.bytes, bytes)
    return length(bytes)
end

Base.flush(output::_McpAdmissionOutput) = output.open ? nothing : error("private closed output")
Base.isopen(output::_McpAdmissionOutput) = output.open
Base.close(output::_McpAdmissionOutput) = (output.open = false)

_mcp_admission_authorization(value = "principal") = UInt8[codeunits(value)...]

function _mcp_admission_repo_file(path::AbstractString)
    return joinpath(REPO_ROOT, split(path, '/')...)
end

function _mcp_admission_read_object(path::AbstractString)
    return JSON3.read(read(_mcp_admission_repo_file(path), String), Dict{String,Any})
end

function _mcp_admission_frame(id::AbstractString)
    rows = _MCP_ADMISSION_CORPUS["frames"]
    position = findfirst(row -> row["id"] == id, rows)
    position === nothing && error("missing MCP frame $id")
    length(rows) == length(_MCP_ADMISSION_FRAME_LINES) ||
        error("canonical frame order is incomplete")
    return JSON3.read(_MCP_ADMISSION_FRAME_LINES[position], Dict{String,Any})
end

function _mcp_admission_frame_bytes(value)
    bytes = UInt8[codeunits(LinkedSpecJulia._mcp_canonical_json(value))...]
    push!(bytes, UInt8('\n'))
    return bytes
end

_mcp_admission_error_bytes(code, message) = _mcp_admission_frame_bytes(
    Dict{String,Any}(
        "jsonrpc" => "2.0",
        "id" => nothing,
        "error" => Dict{String,Any}("code" => code, "message" => message),
    ),
)

function _mcp_admission_with_handle!(request, handle)
    request["params"]["arguments"]["handle"] = handle
    return request
end

function _mcp_admission_with_julia_identity!(response)
    response["result"]["_meta"]["io.modelcontextprotocol/serverInfo"]["name"] =
        _MCP_ADMISSION_SERVER_NAME
    return response
end

function _mcp_admission_raw_fixture(row)
    encoding = row["encoding"]
    if encoding == "hex"
        return _mcp_admission_decode_hex(row["data"])
    elseif encoding == "utf8"
        return UInt8[codeunits(row["data"])...]
    elseif encoding == "repeat_hex"
        byte = only(_mcp_admission_decode_hex(row["byte"]))
        return vcat(
            fill(byte, Int(row["count"])),
            _mcp_admission_decode_hex(row["suffix"]),
        )
    elseif encoding == "nested_json"
        depth = Int(row["depth"])
        return vcat(
            fill(UInt8('['), depth),
            UInt8['0'],
            fill(UInt8(']'), depth),
            UInt8['\n'],
        )
    end
    error("unknown raw fixture encoding $encoding")
end

function _mcp_admission_decode_hex(hex::AbstractString)
    iseven(length(hex)) || error("hex fixture has a partial byte")
    return UInt8[
        parse(UInt8, hex[offset:(offset + 1)]; base = 16) for offset in 1:2:length(hex)
    ]
end

function _mcp_admission_run_stdio(
    bytes;
    server = McpServer(),
    authorization = "stdio-principal",
)
    input = IOBuffer(collect(UInt8, bytes))
    output = IOBuffer()
    log = IOBuffer()
    serve_mcp_stdio!(
        server,
        input,
        output,
        _mcp_admission_authorization(authorization);
        log,
    )
    return take!(output), take!(log), isopen(input), isopen(output), isopen(log)
end

function _mcp_admission_error(call, code)
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

function _mcp_admission_role!(proof, roles_seen, role)
    push!(roles_seen, role)
    proof()
    return nothing
end

@testset "exact Julia MCP admission executes every role once" begin
    roles_seen = String[]

    _mcp_admission_role!(roles_seen, "contract_inventory") do
        frames = _MCP_ADMISSION_CORPUS["frames"]
        @test [row["id"] for row in frames] == _MCP_ADMISSION_CORPUS["canonical_order"]
        @test length(frames) == 35
        @test [row["id"] for row in _MCP_ADMISSION_CORPUS["raw_inputs"]] ==
              _MCP_ADMISSION_RAW_IDS
        @test [row["id"] for row in _MCP_ADMISSION_CORPUS["lifecycle_cases"]] ==
              _MCP_ADMISSION_LIFECYCLE_IDS
        @test [row["state"] for row in _MCP_ADMISSION_CORPUS["handle_cases"]] ==
              _MCP_ADMISSION_HANDLE_STATES
        @test [row["id"] for row in _MCP_ADMISSION_CORPUS["policy_cases"]] ==
              _MCP_ADMISSION_POLICY_IDS
        @test length(_MCP_ADMISSION_FRAME_LINES) == 35
        for line in _MCP_ADMISSION_FRAME_LINES
            @test LinkedSpecJulia._mcp_canonical_json(
                JSON3.read(line, Dict{String,Any}),
            ) == line
        end
        validator = _mcp_admission_read_object(
            "capability_conformance/mcp_semantic_transport/validator_cases.json",
        )
        @test length(validator["mutation_order"]) == 68
        transport = _mcp_admission_read_object(
            "capability_conformance/mcp_semantic_transport_contract.json",
        )
        @test transport["contract_id"] == "linkedspec-mcp-transport-v1"
        @test transport["protocol_version"] == "2026-07-28"
    end

    _mcp_admission_role!(roles_seen, "canonical_static_dispatch") do
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
            expected = _mcp_admission_frame(response_id)
            julia_identity && _mcp_admission_with_julia_identity!(expected)
            @test dispatch_mcp(
                server,
                _mcp_admission_frame(request_id),
                _mcp_admission_authorization("static-principal"),
            ) == expected
        end
        @test dispatch_mcp(
            server,
            _mcp_admission_frame("legacy_initialized_notification"),
            _mcp_admission_authorization("static-principal"),
        ) === nothing
        shutdown_mcp!(server)
    end

    _mcp_admission_role!(roles_seen, "native_capabilities_identity") do
        native = to_json(semantic_capabilities(_MCP_ADMISSION_GRAPH_INDEX))
        server = McpServer()
        handle = register_index!(
            server,
            _MCP_ADMISSION_GRAPH_INDEX,
            _mcp_admission_authorization("capabilities-principal"),
        )
        actual = dispatch_mcp(
            server,
            _mcp_admission_with_handle!(
                _mcp_admission_frame("capabilities_call_request"),
                handle,
            ),
            _mcp_admission_authorization("capabilities-principal"),
        )
        @test actual == _mcp_admission_with_julia_identity!(
            _mcp_admission_frame("capabilities_call_response"),
        )
        @test actual["result"]["structuredContent"] == native
        @test JSON3.read(
            only(actual["result"]["content"])["text"],
            Dict{String,Any},
        ) == native
        shutdown_mcp!(server)
    end

    _mcp_admission_role!(roles_seen, "native_query_identity") do
        server = McpServer()
        handle = register_index!(
            server,
            _MCP_ADMISSION_GRAPH_INDEX,
            _mcp_admission_authorization("query-principal"),
        )
        request = _mcp_admission_with_handle!(
            _mcp_admission_frame("query_call_request"),
            handle,
        )
        native = to_json(
            semantic_query_neutral(
                _MCP_ADMISSION_GRAPH_INDEX,
                request["params"]["arguments"]["request"],
            ),
        )
        actual = dispatch_mcp(
            server,
            request,
            _mcp_admission_authorization("query-principal"),
        )
        @test actual == _mcp_admission_with_julia_identity!(
            _mcp_admission_frame("query_call_response"),
        )
        @test actual["result"]["structuredContent"] == native
        @test JSON3.read(
            only(actual["result"]["content"])["text"],
            Dict{String,Any},
        ) == native
        shutdown_mcp!(server)
    end

    _mcp_admission_role!(roles_seen, "raw_input_outcomes") do
        for row in _MCP_ADMISSION_CORPUS["raw_inputs"]
            id = row["id"]
            output, log, input_open, output_open, log_open = _mcp_admission_run_stdio(
                _mcp_admission_raw_fixture(row);
                authorization = "raw-principal",
            )
            expected = if id == "valid_crlf_discovery"
                response = _mcp_admission_frame("discover_response_julia")
                response["id"] = 1
                _mcp_admission_frame_bytes(response)
            else
                outcome = row["expected"]
                _mcp_admission_error_bytes(outcome["code"], outcome["message"])
            end
            @test output == expected
            @test isempty(log)
            @test input_open && output_open && log_open
        end
    end

    _mcp_admission_role!(roles_seen, "lifecycle_outcomes") do
        lifecycle = _MCP_ADMISSION_CORPUS["lifecycle_cases"]
        @test length(lifecycle) == 10
        @test first(lifecycle)["expected"] == "dispatch_without_handshake"

        ready, ready_log, _, _, _ = _mcp_admission_run_stdio(
            _mcp_admission_frame_bytes(_mcp_admission_frame("discover_request"));
            authorization = "ready-principal",
        )
        @test ready == _mcp_admission_frame_bytes(
            _mcp_admission_frame("discover_response_julia"),
        )
        @test !in(UInt8('\r'), ready)
        @test isempty(ready_log)

        unknown_cancel, _, _, _, _ = _mcp_admission_run_stdio(
            _mcp_admission_frame_bytes(_mcp_admission_frame("cancelled_notification"));
            authorization = "cancel-principal",
        )
        @test isempty(unknown_cancel)

        request = _mcp_admission_frame("discover_request")
        cancellation = _mcp_admission_frame("cancelled_notification")
        cancellation["params"]["requestId"] = request["id"]
        late_cancel, _, _, _, _ = _mcp_admission_run_stdio(
            vcat(
                _mcp_admission_frame_bytes(request),
                _mcp_admission_frame_bytes(cancellation),
            );
            authorization = "cancel-principal",
        )
        @test late_cancel == _mcp_admission_frame_bytes(
            _mcp_admission_frame("discover_response_julia"),
        )

        legacy, _, _, _, _ = _mcp_admission_run_stdio(
            _mcp_admission_frame_bytes(
                _mcp_admission_frame("legacy_initialized_notification"),
            );
            authorization = "legacy-principal",
        )
        @test isempty(legacy)

        transport = _mcp_admission_read_object(
            "capability_conformance/mcp_semantic_transport_contract.json",
        )
        maximum = Int(transport["handle_registry"]["default_maximum_live_handles"])
        capacity = McpServer()
        register_index!(
            capacity,
            _MCP_ADMISSION_GRAPH_INDEX,
            _mcp_admission_authorization("capacity-principal");
            options = McpRegistrationOptions(lifetime_ms = 1),
        )
        sleep(0.003)
        for _ in 1:maximum
            register_index!(
                capacity,
                _MCP_ADMISSION_GRAPH_INDEX,
                _mcp_admission_authorization("capacity-principal"),
            )
        end
        _mcp_admission_error("linkedspec_mcp_registry_full") do
            register_index!(
                capacity,
                _MCP_ADMISSION_GRAPH_INDEX,
                _mcp_admission_authorization("capacity-principal"),
            )
        end
        shutdown_mcp!(capacity)

        graceful = McpServer()
        register_index!(
            graceful,
            _MCP_ADMISSION_GRAPH_INDEX,
            _mcp_admission_authorization("eof-principal"),
        )
        serve_mcp_stdio!(
            graceful,
            IOBuffer(),
            IOBuffer(),
            _mcp_admission_authorization("eof-principal"),
        )
        _mcp_admission_error("linkedspec_mcp_server_shutdown") do
            register_index!(
                graceful,
                _MCP_ADMISSION_GRAPH_INDEX,
                _mcp_admission_authorization("eof-principal"),
            )
        end

        failure = McpServer()
        failure_output = _McpAdmissionOutput()
        failure_log = _McpAdmissionOutput()
        _mcp_admission_error("linkedspec_mcp_io_failure") do
            serve_mcp_stdio!(
                failure,
                _McpAdmissionFailingInput(),
                failure_output,
                _mcp_admission_authorization("failure-principal");
                log = failure_log,
            )
        end
        @test isempty(failure_output.bytes)
        @test String(failure_log.bytes) == _MCP_ADMISSION_IO_LOG
    end

    _mcp_admission_role!(roles_seen, "handle_state_indistinguishability") do
        expected = _mcp_admission_with_julia_identity!(
            _mcp_admission_frame("handle_unavailable_response"),
        )
        index = _MCP_ADMISSION_GRAPH_INDEX

        unknown = McpServer()
        @test dispatch_mcp(
            unknown,
            _mcp_admission_frame("handle_unavailable_request"),
            _mcp_admission_authorization("state-principal"),
        ) == expected
        shutdown_mcp!(unknown)

        expired = McpServer()
        expired_handle = register_index!(
            expired,
            index,
            _mcp_admission_authorization("state-principal");
            options = McpRegistrationOptions(lifetime_ms = 1),
        )
        sleep(0.003)
        @test dispatch_mcp(
            expired,
            _mcp_admission_with_handle!(
                _mcp_admission_frame("handle_unavailable_request"),
                expired_handle,
            ),
            _mcp_admission_authorization("state-principal"),
        ) == expected
        shutdown_mcp!(expired)

        revoked = McpServer()
        revoked_handle = register_index!(
            revoked,
            index,
            _mcp_admission_authorization("state-principal"),
        )
        revoke_handle!(revoked, revoked_handle)
        @test dispatch_mcp(
            revoked,
            _mcp_admission_with_handle!(
                _mcp_admission_frame("handle_unavailable_request"),
                revoked_handle,
            ),
            _mcp_admission_authorization("state-principal"),
        ) == expected
        shutdown_mcp!(revoked)

        unauthorized = McpServer()
        unauthorized_handle = register_index!(
            unauthorized,
            index,
            _mcp_admission_authorization("state-principal"),
        )
        @test dispatch_mcp(
            unauthorized,
            _mcp_admission_with_handle!(
                _mcp_admission_frame("handle_unavailable_request"),
                unauthorized_handle,
            ),
            _mcp_admission_authorization("wrong-principal"),
        ) == expected
        shutdown_mcp!(unauthorized)
    end

    _mcp_admission_role!(roles_seen, "policy_overlay") do
        server = McpServer()
        default_handle = register_index!(
            server,
            _MCP_ADMISSION_GRAPH_INDEX,
            _mcp_admission_authorization("default-policy-principal"),
        )
        @test dispatch_mcp(
            server,
            _mcp_admission_with_handle!(
                _mcp_admission_frame("capabilities_call_request"),
                default_handle,
            ),
            _mcp_admission_authorization("default-policy-principal"),
        ) == _mcp_admission_with_julia_identity!(
            _mcp_admission_frame("capabilities_call_response"),
        )
        @test dispatch_mcp(
            server,
            _mcp_admission_with_handle!(
                _mcp_admission_frame("query_call_request"),
                default_handle,
            ),
            _mcp_admission_authorization("default-policy-principal"),
        ) == _mcp_admission_with_julia_identity!(
            _mcp_admission_frame("query_call_response"),
        )

        restricted = register_index!(
            server,
            _MCP_ADMISSION_GRAPH_INDEX,
            _mcp_admission_authorization("restricted-policy-principal");
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
            _mcp_admission_with_handle!(
                _mcp_admission_frame("restricted_capabilities_request"),
                restricted,
            ),
            _mcp_admission_authorization("restricted-policy-principal"),
        ) == _mcp_admission_with_julia_identity!(
            _mcp_admission_frame("restricted_capabilities_response"),
        )
        @test dispatch_mcp(
            server,
            _mcp_admission_with_handle!(
                _mcp_admission_frame("policy_denied_request"),
                restricted,
            ),
            _mcp_admission_authorization("restricted-policy-principal"),
        ) == _mcp_admission_with_julia_identity!(
            _mcp_admission_frame("policy_denied_response"),
        )
        shutdown_mcp!(server)
    end

    _mcp_admission_role!(roles_seen, "cancellation_emission") do
        before = only(
            row for row in _MCP_ADMISSION_CORPUS["lifecycle_cases"] if
            row["id"] == "cancel_before_response_emission"
        )
        @test before["expected"] == "stop_and_suppress_response"
        focused = read(
            _mcp_admission_repo_file("julia/test/mcp_server_julia_stdio_test.jl"),
            String,
        )
        @test occursin("before_wire_emit =", focused)
        @test occursin("@test isempty(take!(cancellation_output))", focused)
        @test !occursin(r"@testset[^\n]*skip", focused)

        request = _mcp_admission_frame("discover_request")
        cancellation = _mcp_admission_frame("cancelled_notification")
        cancellation["params"]["requestId"] = request["id"]
        output, log, _, _, _ = _mcp_admission_run_stdio(
            vcat(
                _mcp_admission_frame_bytes(request),
                _mcp_admission_frame_bytes(cancellation),
            );
            authorization = "emission-principal",
        )
        @test output == _mcp_admission_frame_bytes(
            _mcp_admission_frame("discover_response_julia"),
        )
        @test isempty(log)
    end

    _mcp_admission_role!(roles_seen, "shutdown_and_io") do
        complete = _mcp_admission_frame_bytes(_mcp_admission_frame("discover_request"))
        later = McpServer()
        later_output = _McpAdmissionOutput()
        later_log = _McpAdmissionOutput()
        _mcp_admission_error("linkedspec_mcp_io_failure") do
            serve_mcp_stdio!(
                later,
                _McpAdmissionFailingAfter(complete, 1),
                later_output,
                _mcp_admission_authorization("later-failure-principal");
                log = later_log,
            )
        end
        @test later_output.bytes == _mcp_admission_frame_bytes(
            _mcp_admission_frame("discover_response_julia"),
        )
        @test String(later_log.bytes) == _MCP_ADMISSION_IO_LOG
        @test isopen(later_output) && isopen(later_log)

        output_failure = McpServer()
        register_index!(
            output_failure,
            _MCP_ADMISSION_GRAPH_INDEX,
            _mcp_admission_authorization("write-failure-principal"),
        )
        broken_output = _McpAdmissionOutput(fail_write = true)
        output_log = _McpAdmissionOutput()
        _mcp_admission_error("linkedspec_mcp_io_failure") do
            serve_mcp_stdio!(
                output_failure,
                IOBuffer(complete),
                broken_output,
                _mcp_admission_authorization("write-failure-principal");
                log = output_log,
            )
        end
        @test String(output_log.bytes) == _MCP_ADMISSION_IO_LOG
        _mcp_admission_error("linkedspec_mcp_server_shutdown") do
            register_index!(
                output_failure,
                _MCP_ADMISSION_GRAPH_INDEX,
                _mcp_admission_authorization("write-failure-principal"),
            )
        end
    end

    _mcp_admission_role!(roles_seen, "hostile_output_and_log_privacy") do
        server = McpServer()
        output = _McpAdmissionOutput()
        log = _McpAdmissionOutput()
        failure = _mcp_admission_error("linkedspec_mcp_io_failure") do
            serve_mcp_stdio!(
                server,
                _McpAdmissionFailingInput(),
                output,
                _mcp_admission_authorization("hostile-principal");
                log,
            )
        end
        @test isempty(output.bytes)
        @test String(log.bytes) == _MCP_ADMISSION_IO_LOG
        exposed = String(output.bytes) * String(log.bytes) * sprint(showerror, failure)
        for forbidden in ("private/", "secret", "handle=", "auth=", "principal")
            @test !occursin(forbidden, exposed)
        end

        native_focused = read(
            _mcp_admission_repo_file("julia/test/mcp_server_julia_dispatch_test.jl"),
            String,
        )
        @test occursin(
            "native failures are sanitized and cancellation suppresses preparation",
            native_focused,
        )
        @test occursin("mode[] = :throw", native_focused)
        @test !occursin(r"@testset[^\n]*skip", native_focused)
    end

    _mcp_admission_role!(roles_seen, "authority_surface_fences") do
        paths = [
            "julia/src/mcp/McpContract.jl",
            "julia/src/mcp/McpContractRuntime.jl",
            "julia/src/mcp/McpServer.jl",
            "julia/src/mcp/McpWire.jl",
        ]
        production = join(
            [read(_mcp_admission_repo_file(path), String) for path in paths],
            '\n',
        )
        for forbidden in (
            "open(",
            "rm(",
            "mkpath(",
            "ENV[",
            "run(",
            "Cmd(",
            "Sockets",
            "Downloads",
            "HTTP",
            "@async",
            "Threads.",
            "Channel",
            "parse_spec(",
            "compile_spec(",
            "load_spec(",
            "LinkedSpecRuntimeEngine",
            "LINKEDSPEC_TRACE_LEVEL",
            "emit_julia_source",
        )
            @test !occursin(forbidden, production)
        end
        module_source = read(
            _mcp_admission_repo_file("julia/src/LinkedSpecJulia.jl"),
            String,
        )
        for include in (
            "include(\"mcp/McpContract.jl\")",
            "include(\"mcp/McpContractRuntime.jl\")",
            "include(\"mcp/McpServer.jl\")",
            "include(\"mcp/McpWire.jl\")",
        )
            @test count(==(include), split(module_source, '\n')) == 1
        end
        exported = Set(names(LinkedSpecJulia))
        for name in (
            :McpServer,
            :register_index!,
            :revoke_handle!,
            :dispatch_mcp,
            :serve_mcp_stdio!,
            :shutdown_mcp!,
        )
            @test name in exported
        end
        primary = read(
            _mcp_admission_repo_file("julia/bin/linkedspec_julia.jl"),
            String,
        )
        @test !occursin("McpServer", primary)
        @test !occursin("dispatch_mcp", primary)
        @test !occursin("serve_mcp_stdio!", primary)
        project = read(_mcp_admission_repo_file("julia/Project.toml"), String)
        for dependency in ("Base64", "JSON3", "Random", "SHA")
            @test occursin(Regex("^" * dependency * " = ", "m"), project)
        end
    end

    @test roles_seen == _MCP_ADMISSION_ROLE_ORDER
end
