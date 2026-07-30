# FUTURE-PARITY-BACKLOG.10.9.5.2 — public Julia MCP stdio/lifecycle proof.

import JSON3

const _MCP_WIRE_TEST_SERVER_NAME = "linkedspec-semantic-julia"
const _MCP_WIRE_TEST_IO_LOG = "linkedspec_mcp_io_failure\n"
const _MCP_WIRE_TEST_CORPUS = JSON3.read(
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
const _MCP_WIRE_TEST_FRAME_LINES = readlines(
    joinpath(
        REPO_ROOT,
        "capability_conformance",
        "mcp_semantic_transport",
        "canonical_frames.jsonl",
    ),
)
const _MCP_WIRE_TEST_GRAPH_INDEX = semantic_index(
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

mutable struct _McpWireTestChunkedInput <: IO
    bytes::Vector{UInt8}
    widths::Vector{Int}
    offset::Int
    width_index::Int
    remaining::Int
    open::Bool
end

function _McpWireTestChunkedInput(bytes, widths)
    return _McpWireTestChunkedInput(
        collect(UInt8, bytes),
        collect(Int, widths),
        1,
        1,
        0,
        true,
    )
end

function Base.readbytes!(
    input::_McpWireTestChunkedInput,
    target::AbstractArray{UInt8},
    requested = length(target),
)
    input.open || error("private closed chunk input")
    input.offset > length(input.bytes) && return 0
    if input.remaining == 0
        width = input.widths[input.width_index]
        input.width_index = input.width_index == length(input.widths) ? 1 :
                            input.width_index + 1
        input.remaining = min(width, length(input.bytes) - input.offset + 1)
    end
    count = min(Int(requested), input.remaining, length(target))
    copyto!(target, 1, input.bytes, input.offset, count)
    input.offset += count
    input.remaining -= count
    return count
end

Base.bytesavailable(input::_McpWireTestChunkedInput) = input.remaining
Base.isopen(input::_McpWireTestChunkedInput) = input.open
Base.close(input::_McpWireTestChunkedInput) = (input.open = false)

struct _McpWireTestFailingInput <: IO end

Base.readbytes!(::_McpWireTestFailingInput, ::AbstractArray{UInt8}, requested = 0) =
    error("private input path, request, and principal")
Base.bytesavailable(::_McpWireTestFailingInput) = 0
Base.isopen(::_McpWireTestFailingInput) = true

mutable struct _McpWireTestFailingAfter <: IO
    bytes::Vector{UInt8}
    offset::Int
end

function Base.readbytes!(
    input::_McpWireTestFailingAfter,
    target::AbstractArray{UInt8},
    requested = length(target),
)
    input.offset > length(input.bytes) && error("private later input failure")
    count = min(Int(requested), length(target), length(input.bytes) - input.offset + 1)
    copyto!(target, 1, input.bytes, input.offset, count)
    input.offset += count
    return count
end

Base.bytesavailable(input::_McpWireTestFailingAfter) =
    max(0, length(input.bytes) - input.offset + 1)
Base.isopen(::_McpWireTestFailingAfter) = true

mutable struct _McpWireTestOutput <: IO
    bytes::Vector{UInt8}
    fail_write::Bool
    fail_flush::Bool
    open::Bool
end

_McpWireTestOutput(; fail_write = false, fail_flush = false) =
    _McpWireTestOutput(UInt8[], fail_write, fail_flush, true)

function Base.write(output::_McpWireTestOutput, bytes::StridedVector{UInt8})
    output.open || error("private closed output")
    output.fail_write && error("private output path, handle, and response")
    append!(output.bytes, bytes)
    return length(bytes)
end

function Base.flush(output::_McpWireTestOutput)
    output.open || error("private closed output")
    output.fail_flush && error("private flush path and object")
    return nothing
end

Base.isopen(output::_McpWireTestOutput) = output.open
Base.close(output::_McpWireTestOutput) = (output.open = false)

_mcp_wire_test_authorization(value = "wire-principal") = UInt8[codeunits(value)...]

function _mcp_wire_test_frame(id::String)
    rows = _MCP_WIRE_TEST_CORPUS["frames"]
    position = findfirst(row -> row["id"] == id, rows)
    position === nothing && error("missing MCP frame $id")
    length(rows) == length(_MCP_WIRE_TEST_FRAME_LINES) ||
        error("canonical frame order is incomplete")
    return JSON3.read(_MCP_WIRE_TEST_FRAME_LINES[position], Dict{String,Any})
end

function _mcp_wire_test_with_handle!(request, handle)
    request["params"]["arguments"]["handle"] = handle
    return request
end

function _mcp_wire_test_with_julia_identity!(response)
    response["result"]["_meta"]["io.modelcontextprotocol/serverInfo"]["name"] =
        _MCP_WIRE_TEST_SERVER_NAME
    return response
end

function _mcp_wire_test_frame_bytes(value)
    bytes = UInt8[codeunits(LinkedSpecJulia._mcp_canonical_json(value))...]
    push!(bytes, UInt8('\n'))
    return bytes
end

_mcp_wire_test_error_bytes(code, message) = _mcp_wire_test_frame_bytes(
    Dict{String,Any}(
        "jsonrpc" => "2.0",
        "id" => nothing,
        "error" => Dict{String,Any}("code" => code, "message" => message),
    ),
)

function _mcp_wire_test_raw_fixture(row)
    encoding = row["encoding"]
    if encoding == "hex"
        return _mcp_wire_test_decode_hex(row["data"])
    elseif encoding == "utf8"
        return UInt8[codeunits(row["data"])...]
    elseif encoding == "repeat_hex"
        byte = only(_mcp_wire_test_decode_hex(row["byte"]))
        return vcat(fill(byte, Int(row["count"])), _mcp_wire_test_decode_hex(row["suffix"]))
    elseif encoding == "nested_json"
        depth = Int(row["depth"])
        return vcat(fill(UInt8('['), depth), UInt8['0'], fill(UInt8(']'), depth), UInt8['\n'])
    end
    error("unknown raw fixture encoding $encoding")
end

function _mcp_wire_test_decode_hex(hex::AbstractString)
    iseven(length(hex)) || error("hex fixture has a partial byte")
    return UInt8[
        parse(UInt8, hex[offset:(offset + 1)]; base = 16) for offset in 1:2:length(hex)
    ]
end

function _mcp_wire_test_server(; before_wire_emit = nothing)
    return LinkedSpecJulia._mcp_test_server(
        entropy = () -> fill(UInt8(0x5a), 32),
        now_ms = () -> 10_000,
        before_wire_emit = before_wire_emit,
    )
end

function _mcp_wire_test_output(bytes; server = _mcp_wire_test_server())
    input = IOBuffer(collect(UInt8, bytes))
    output = IOBuffer()
    serve_mcp_stdio!(
        server,
        input,
        output,
        _mcp_wire_test_authorization(),
    )
    return take!(output)
end

function _mcp_wire_test_error(call, code)
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

@testset "Julia native MCP strict stdio" begin
    @testset "public stdio matches every neutral raw classification" begin
        for row in _MCP_WIRE_TEST_CORPUS["raw_inputs"]
            id = row["id"]
            server = _mcp_wire_test_server()
            input = IOBuffer(_mcp_wire_test_raw_fixture(row))
            output = IOBuffer()
            log = IOBuffer()
            serve_mcp_stdio!(
                server,
                input,
                output,
                _mcp_wire_test_authorization("raw-principal");
                log,
            )
            expected = if id == "valid_crlf_discovery"
                response = _mcp_wire_test_frame("discover_response_julia")
                response["id"] = 1
                _mcp_wire_test_frame_bytes(response)
            else
                outcome = row["expected"]
                _mcp_wire_test_error_bytes(outcome["code"], outcome["message"])
            end
            @test take!(output) == expected
            @test isempty(take!(log))
            @test isopen(input)
            @test isopen(output)
            @test isopen(log)
            @test LinkedSpecJulia._mcp_registered_handles(server) == 0
            @test LinkedSpecJulia._mcp_active_requests(server) == 0
        end
    end

    @testset "lexical identity, depth, numbers, ids, and line limits are exact" begin
        parse_error = _mcp_wire_test_error_bytes(-32700, "Parse error")
        invalid_request = _mcp_wire_test_error_bytes(-32600, "Invalid Request")
        for text in (
            "{\"\\u0069d\":1,\"id\":2,\"jsonrpc\":\"2.0\",\"method\":\"server/discover\",\"params\":{}}\n",
            "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"server/discover\",\"params\":{\"x\":{\"a\":1,\"\\u0061\":2}}}\n",
            "{\"id\":\"\\uD800\",\"jsonrpc\":\"2.0\",\"method\":\"server/discover\",\"params\":{}}\n",
            "{\"id\":NaN,\"jsonrpc\":\"2.0\",\"method\":\"server/discover\",\"params\":{}}\n",
            "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"server/discover\",\"params\":{\"value\":1e999}}\n",
            "\n",
        )
            @test _mcp_wire_test_output(UInt8[codeunits(text)...]) == parse_error
        end

        depth64 = vcat(
            fill(UInt8('['), 64),
            UInt8['0'],
            fill(UInt8(']'), 64),
            UInt8['\n'],
        )
        @test _mcp_wire_test_output(depth64) == invalid_request

        maximum = UInt8[
            codeunits(
                LinkedSpecJulia._mcp_canonical_json(
                    _mcp_wire_test_frame("discover_request"),
                ),
            )...,
        ]
        append!(maximum, fill(UInt8(' '), 1_048_576 - length(maximum)))
        append!(maximum, UInt8['\r', '\n'])
        @test _mcp_wire_test_output(maximum) ==
              _mcp_wire_test_frame_bytes(_mcp_wire_test_frame("discover_response_julia"))

        for id in ("1.0", "1e0", "9007199254740992", "-9007199254740992", "null")
            bytes = UInt8[
                codeunits(
                    "{\"id\":$id,\"jsonrpc\":\"2.0\",\"method\":\"server/discover\",\"params\":{}}\n",
                )...,
            ]
            @test _mcp_wire_test_output(bytes) == invalid_request
        end
        for id in (-9_007_199_254_740_991, 9_007_199_254_740_991)
            request = _mcp_wire_test_frame("discover_request")
            request["id"] = id
            expected = _mcp_wire_test_frame("discover_response_julia")
            expected["id"] = id
            @test _mcp_wire_test_output(_mcp_wire_test_frame_bytes(request)) ==
                  _mcp_wire_test_frame_bytes(expected)
        end

        for (characters, accepted) in ((64, true), (65, false))
            id = repeat("é", characters)
            request = _mcp_wire_test_frame("discover_request")
            request["id"] = id
            output = _mcp_wire_test_output(_mcp_wire_test_frame_bytes(request))
            if accepted
                expected = _mcp_wire_test_frame("discover_response_julia")
                expected["id"] = id
                @test output == _mcp_wire_test_frame_bytes(expected)
                @test occursin(id, String(output))
                @test !occursin("\\u00e9", String(output))
            else
                @test output == invalid_request
            end
        end

        decoded = LinkedSpecJulia._mcp_wire_decode_payload(
            UInt8[
                codeunits(
                    "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"server/discover\",\"params\":{\"values\":[-0,-0.0,1e0,2]}}",
                )...,
            ],
            64,
        )
        values = decoded["params"]["values"]
        @test values[1] === 0
        @test values[2] isa Float64 && iszero(values[2]) && signbit(values[2])
        @test values[3] === 1.0
        @test values[4] === 2
    end

    @testset "framing recovers, canonical responses flush, and cancellation is exact" begin
        list = _mcp_wire_test_frame("tools_list_request")
        expected_list = _mcp_wire_test_frame_bytes(
            _mcp_wire_test_with_julia_identity!(
                _mcp_wire_test_frame("tools_list_response_perl"),
            ),
        )
        @test _mcp_wire_test_output(
            vcat(UInt8['{', '\n'], _mcp_wire_test_frame_bytes(list)),
        ) == vcat(_mcp_wire_test_error_bytes(-32700, "Parse error"), expected_list)
        @test _mcp_wire_test_output(
            vcat(fill(UInt8('x'), 1_048_577), UInt8['\n'], _mcp_wire_test_frame_bytes(list)),
        ) == vcat(_mcp_wire_test_error_bytes(-32700, "Parse error"), expected_list)
        @test _mcp_wire_test_output(fill(UInt8('x'), 1_048_577)) ==
              _mcp_wire_test_error_bytes(-32700, "Parse error")

        final_request = _mcp_wire_test_frame("discover_request")
        final_request["id"] = "réq"
        no_newline = _mcp_wire_test_frame_bytes(final_request)
        pop!(no_newline)
        expected_final = _mcp_wire_test_frame("discover_response_julia")
        expected_final["id"] = "réq"
        @test _mcp_wire_test_output(no_newline) == _mcp_wire_test_frame_bytes(expected_final)

        server = _mcp_wire_test_server()
        handle = register_index!(
            server,
            _MCP_WIRE_TEST_GRAPH_INDEX,
            _mcp_wire_test_authorization(),
        )
        requests = Any[
            _mcp_wire_test_frame("discover_request"),
            list,
            _mcp_wire_test_with_handle!(
                _mcp_wire_test_frame("capabilities_call_request"),
                handle,
            ),
            _mcp_wire_test_with_handle!(
                _mcp_wire_test_frame("query_call_request"),
                handle,
            ),
            _mcp_wire_test_frame("legacy_initialized_notification"),
        ]
        wire = reduce(vcat, _mcp_wire_test_frame_bytes.(requests))
        input = _McpWireTestChunkedInput(wire, [1, 7, 65_535, 3, 29])
        output = IOBuffer()
        serve_mcp_stdio!(server, input, output, _mcp_wire_test_authorization())
        expected = reduce(
            vcat,
            _mcp_wire_test_frame_bytes.([
                _mcp_wire_test_frame("discover_response_julia"),
                _mcp_wire_test_with_julia_identity!(
                    _mcp_wire_test_frame("tools_list_response_perl"),
                ),
                _mcp_wire_test_with_julia_identity!(
                    _mcp_wire_test_frame("capabilities_call_response"),
                ),
                _mcp_wire_test_with_julia_identity!(
                    _mcp_wire_test_frame("query_call_response"),
                ),
            ]),
        )
        @test take!(output) == expected
        @test !in(UInt8('\r'), expected)
        @test isopen(input)
        @test isopen(output)
        @test LinkedSpecJulia._mcp_registered_handles(server) == 0
        @test LinkedSpecJulia._mcp_active_requests(server) == 0

        cancelled = Ref(false)
        authorization = _mcp_wire_test_authorization("cancel-principal")
        cancellation_server = _mcp_wire_test_server(
            before_wire_emit = (active_server, prepared) -> begin
                prepared isa String || return
                cancelled[] && return
                cancelled[] = true
                notification = _mcp_wire_test_frame("cancelled_notification")
                notification["params"]["requestId"] = JSON3.read(prepared)
                @test dispatch_mcp(active_server, notification, authorization) === nothing
            end,
        )
        cancellation_output = IOBuffer()
        serve_mcp_stdio!(
            cancellation_server,
            IOBuffer(_mcp_wire_test_frame_bytes(_mcp_wire_test_frame("discover_request"))),
            cancellation_output,
            authorization,
        )
        @test cancelled[]
        @test isempty(take!(cancellation_output))
        @test LinkedSpecJulia._mcp_active_requests(cancellation_server) == 0

        late_request = _mcp_wire_test_frame("discover_request")
        late_cancel = _mcp_wire_test_frame("cancelled_notification")
        late_cancel["params"]["requestId"] = late_request["id"]
        @test _mcp_wire_test_output(
            vcat(
                _mcp_wire_test_frame_bytes(late_request),
                _mcp_wire_test_frame_bytes(late_cancel),
            ),
        ) == _mcp_wire_test_frame_bytes(_mcp_wire_test_frame("discover_response_julia"))
    end

    @testset "EOF and every hostile IO path release and sanitize" begin
        clean = _mcp_wire_test_server()
        register_index!(
            clean,
            _MCP_WIRE_TEST_GRAPH_INDEX,
            _mcp_wire_test_authorization("clean-release-principal"),
        )
        clean_input = IOBuffer()
        clean_output = IOBuffer()
        serve_mcp_stdio!(
            clean,
            clean_input,
            clean_output,
            _mcp_wire_test_authorization("clean-release-principal"),
        )
        @test LinkedSpecJulia._mcp_registered_handles(clean) == 0
        @test isopen(clean_input)
        @test isopen(clean_output)
        _mcp_wire_test_error(
            () -> serve_mcp_stdio!(
                clean,
                IOBuffer(),
                IOBuffer(),
                _mcp_wire_test_authorization(),
            ),
            "linkedspec_mcp_server_shutdown",
        )

        input_failure = _mcp_wire_test_server()
        register_index!(
            input_failure,
            _MCP_WIRE_TEST_GRAPH_INDEX,
            _mcp_wire_test_authorization("input-private-principal"),
        )
        input_output = _McpWireTestOutput()
        input_log = _McpWireTestOutput()
        _mcp_wire_test_error(
            () -> serve_mcp_stdio!(
                input_failure,
                _McpWireTestFailingInput(),
                input_output,
                _mcp_wire_test_authorization("input-private-principal");
                log = input_log,
            ),
            "linkedspec_mcp_io_failure",
        )
        @test isempty(input_output.bytes)
        @test String(input_log.bytes) == _MCP_WIRE_TEST_IO_LOG
        @test LinkedSpecJulia._mcp_registered_handles(input_failure) == 0

        later_failure = _mcp_wire_test_server()
        later_output = _McpWireTestOutput()
        later_log = _McpWireTestOutput()
        discover_bytes = _mcp_wire_test_frame_bytes(_mcp_wire_test_frame("discover_request"))
        _mcp_wire_test_error(
            () -> serve_mcp_stdio!(
                later_failure,
                _McpWireTestFailingAfter(discover_bytes, 1),
                later_output,
                _mcp_wire_test_authorization("later-private-principal");
                log = later_log,
            ),
            "linkedspec_mcp_io_failure",
        )
        @test later_output.bytes ==
              _mcp_wire_test_frame_bytes(_mcp_wire_test_frame("discover_response_julia"))
        @test String(later_log.bytes) == _MCP_WIRE_TEST_IO_LOG

        output_failure = _mcp_wire_test_server()
        register_index!(
            output_failure,
            _MCP_WIRE_TEST_GRAPH_INDEX,
            _mcp_wire_test_authorization("output-private-principal"),
        )
        hostile_output = _McpWireTestOutput(fail_write = true)
        output_log = _McpWireTestOutput()
        _mcp_wire_test_error(
            () -> serve_mcp_stdio!(
                output_failure,
                IOBuffer(discover_bytes),
                hostile_output,
                _mcp_wire_test_authorization("output-private-principal");
                log = output_log,
            ),
            "linkedspec_mcp_io_failure",
        )
        @test String(output_log.bytes) == _MCP_WIRE_TEST_IO_LOG
        @test LinkedSpecJulia._mcp_registered_handles(output_failure) == 0
        for private_word in (
            "graph",
            "handle",
            "principal",
            "source",
            "request",
            "response",
            "path",
            "object",
            "exception",
        )
            @test !occursin(private_word, String(output_log.bytes))
        end

        flush_failure = _mcp_wire_test_server()
        flush_output = _McpWireTestOutput(fail_flush = true)
        flush_log = _McpWireTestOutput()
        _mcp_wire_test_error(
            () -> serve_mcp_stdio!(
                flush_failure,
                IOBuffer(discover_bytes),
                flush_output,
                _mcp_wire_test_authorization("flush-private-principal");
                log = flush_log,
            ),
            "linkedspec_mcp_io_failure",
        )
        @test flush_output.bytes ==
              _mcp_wire_test_frame_bytes(_mcp_wire_test_frame("discover_response_julia"))
        @test String(flush_log.bytes) == _MCP_WIRE_TEST_IO_LOG

        log_failure = _mcp_wire_test_server()
        _mcp_wire_test_error(
            () -> serve_mcp_stdio!(
                log_failure,
                _McpWireTestFailingInput(),
                _McpWireTestOutput(),
                _mcp_wire_test_authorization();
                log = _McpWireTestOutput(fail_write = true),
            ),
            "linkedspec_mcp_io_failure",
        )

        invalid_arguments = _mcp_wire_test_server()
        unread = IOBuffer(discover_bytes)
        same_output = _McpWireTestOutput()
        _mcp_wire_test_error(
            () -> serve_mcp_stdio!(
                invalid_arguments,
                unread,
                same_output,
                _mcp_wire_test_authorization();
                log = same_output,
            ),
            "linkedspec_mcp_invalid_stdio",
        )
        @test position(unread) == 0
        _mcp_wire_test_error(
            () -> serve_mcp_stdio!(invalid_arguments, unread, IOBuffer(), UInt8[]),
            "linkedspec_mcp_invalid_authorization",
        )
        @test position(unread) == 0
        valid_output = IOBuffer()
        serve_mcp_stdio!(
            invalid_arguments,
            unread,
            valid_output,
            _mcp_wire_test_authorization(),
        )
        @test take!(valid_output) ==
              _mcp_wire_test_frame_bytes(_mcp_wire_test_frame("discover_response_julia"))
    end

    @testset "production wire authority is narrow and dependency-free" begin
        exported = Set(names(LinkedSpecJulia))
        @test :serve_mcp_stdio! in exported
        module_source = read(joinpath(REPO_ROOT, "julia", "src", "LinkedSpecJulia.jl"), String)
        @test count(==("include(\"mcp/McpWire.jl\")"), split(module_source, '\n')) == 1
        runtime = read(
            joinpath(REPO_ROOT, "julia", "src", "mcp", "McpContractRuntime.jl"),
            String,
        )
        server = read(
            joinpath(REPO_ROOT, "julia", "src", "mcp", "McpServer.jl"),
            String,
        )
        wire = read(
            joinpath(REPO_ROOT, "julia", "src", "mcp", "McpWire.jl"),
            String,
        )
        production = runtime * "\n" * server * "\n" * wire
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
        primary = read(
            joinpath(REPO_ROOT, "julia", "bin", "linkedspec_julia.jl"),
            String,
        )
        @test !occursin("McpServer", primary)
        @test !occursin("serve_mcp_stdio!", primary)
    end
end
