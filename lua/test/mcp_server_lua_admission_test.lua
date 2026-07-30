-- FUTURE-PARITY-BACKLOG.10.9.6.3 — exact shared Lua MCP admission.

local linkedspec = require("linkedspec")
local json = linkedspec.json
local mcp = require("linkedspec.mcp_server")
local runtime = require("linkedspec.mcp_contract_runtime")

local ROLE_ORDER = json.array({
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
})

local RAW_IDS = json.array({
  "invalid_utf8", "utf8_bom", "malformed_json", "duplicate_key", "overlong_line",
  "json_batch", "non_object", "invalid_boolean_id", "nesting_depth_65",
  "valid_crlf_discovery",
})
local LIFECYCLE_IDS = json.array({
  "ready_at_stream_loop_start", "cancel_before_response_emission", "cancel_unknown_request",
  "cancel_after_sync_completion", "legacy_initialized_notification", "stdout_discipline",
  "stderr_default", "registry_capacity", "graceful_eof", "unexpected_io_failure",
})
local HANDLE_STATES = json.array({ "unknown", "expired", "revoked", "unauthorized" })
local POLICY_IDS = json.array({
  "default_capabilities_identity", "restricted_capabilities_projection",
  "allowed_query_identity", "above_policy_pre_dispatch_denial",
})
local IO_LOG = "linkedspec_mcp_io_failure\n"

local assertions = 0
local failures = {}

local function check(condition, label)
  assertions = assertions + 1
  if not condition then failures[#failures + 1] = label or "assertion failed" end
end

local function check_equal(actual, expected, label)
  check(actual == expected, (label or "values differ") ..
    ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

local function check_same_json(actual, expected, label)
  check_equal(json.encode(actual), json.encode(expected), label)
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local function read_object(path)
  return json.decode(read_file(path))
end

local function clone(value)
  return runtime.clone_data(value)
end

local function frame(id)
  return assert(runtime.frame(id))
end

local function frame_bytes(value)
  return runtime.canonical_json(value) .. "\n"
end

local function error_bytes(code, message)
  return frame_bytes(json.harray({
    jsonrpc = "2.0",
    id = json.null,
    error = json.harray({ code = code, message = message }),
  }))
end

local function with_handle(value, handle)
  value.params.arguments.handle = handle
  return value
end

local function with_lua_identity(value)
  value.result._meta["io.modelcontextprotocol/serverInfo"].name = mcp.SERVER_NAME
  return value
end

local function find_row(rows, field, value)
  for _, row in ipairs(rows) do
    if row[field] == value then return row end
  end
  error("missing governed row " .. tostring(value), 0)
end

local function field_values(rows, field)
  local result = json.array()
  for index, row in ipairs(rows) do result[index] = row[field] end
  return result
end

local function expect_mcp_error(operation, code, label)
  local ok, value = pcall(operation)
  check_equal(ok, false, label .. " rejected")
  if ok then return nil end
  check(linkedspec.is_mcp_server_error(value), label .. " returns typed MCP error")
  if linkedspec.is_mcp_server_error(value) then
    check_equal(value.code, code, label .. " error code")
    check_equal(getmetatable(value), "protected", label .. " error is protected")
  end
  return value
end

local function decode_hex(hex)
  if #hex % 2 ~= 0 then error("partial fixture byte", 0) end
  local chunks = {}
  for offset = 1, #hex, 2 do
    chunks[#chunks + 1] = string.char(tonumber(hex:sub(offset, offset + 1), 16))
  end
  return table.concat(chunks)
end

local function raw_fixture(row)
  if row.encoding == "hex" then return decode_hex(row.data) end
  if row.encoding == "utf8" then return row.data end
  if row.encoding == "repeat_hex" then
    return string.rep(decode_hex(row.byte), row.count) .. decode_hex(row.suffix)
  end
  if row.encoding == "nested_json" then
    return string.rep("[", row.depth) .. "0" .. string.rep("]", row.depth) .. "\n"
  end
  error("unknown raw fixture encoding", 0)
end

local INPUT_MT = {}
INPUT_MT.__index = INPUT_MT

local function input_stream(data, fail_after)
  return setmetatable({
    data = data or "", position = 1, fail_after = fail_after,
    reads = 0, closed = false,
  }, INPUT_MT)
end

function INPUT_MT:read(count)
  self.reads = self.reads + 1
  if count ~= 1 then error("private invalid read width", 0) end
  if self.fail_after ~= nil and self.position - 1 >= self.fail_after then
    error("private=/private/secret handle=opaque auth=principal request=hidden", 0)
  end
  if self.position > #self.data then return nil end
  local value = self.data:sub(self.position, self.position)
  self.position = self.position + 1
  return value
end

local OUTPUT_MT = {}
OUTPUT_MT.__index = OUTPUT_MT

local function output_stream(options)
  options = options or {}
  return setmetatable({
    chunks = {}, fail_write = options.fail_write,
    fail_flush = options.fail_flush, flushes = 0, closed = false,
  }, OUTPUT_MT)
end

function OUTPUT_MT:write(value)
  if self.fail_write then
    error("private output path, handle, response, and principal", 0)
  end
  self.chunks[#self.chunks + 1] = value
  return self
end

function OUTPUT_MT:flush()
  if self.fail_flush then error("private flush path and object", 0) end
  self.flushes = self.flushes + 1
  return true
end

function OUTPUT_MT:value()
  return table.concat(self.chunks)
end

local function run_stdio(bytes, options)
  options = options or {}
  local server = options.server or linkedspec.mcp_server()
  local input = input_stream(bytes, options.fail_after)
  local output = output_stream(options.output)
  local log = output_stream(options.log)
  server:serve_stdio(input, output, options.authorization or "stdio-principal", { log = log })
  return output:value(), log:value(), input, output, log
end

local function wait_cpu(seconds)
  local deadline = os.clock() + seconds
  while os.clock() < deadline do end
end

local function admission_role(roles_seen, role, proof)
  roles_seen[#roles_seen + 1] = role
  proof()
end

local corpus = runtime.corpus()
local graph_index = linkedspec.semantic_index(read_file(
  "capability_conformance/semantic_introspection/graph.spec"
), { logical_name = "graph.spec", source_detail_ceiling = "text" })
local roles_seen = json.array()

admission_role(roles_seen, "contract_inventory", function()
  check_same_json(field_values(corpus.frames, "id"), corpus.canonical_order,
    "canonical frame order is exact")
  check_equal(#corpus.frames, 35, "canonical frame count")
  check_same_json(field_values(corpus.raw_inputs, "id"), RAW_IDS, "raw input order")
  check_same_json(field_values(corpus.lifecycle_cases, "id"), LIFECYCLE_IDS,
    "lifecycle order")
  check_same_json(field_values(corpus.handle_cases, "state"), HANDLE_STATES,
    "handle-state order")
  check_same_json(field_values(corpus.policy_cases, "id"), POLICY_IDS, "policy order")

  local canonical_lines = json.array()
  for line in read_file(
    "capability_conformance/mcp_semantic_transport/canonical_frames.jsonl"
  ):gmatch("[^\n]+") do
    canonical_lines[#canonical_lines + 1] = line
  end
  check_equal(#canonical_lines, 35, "canonical JSONL line count")
  for index, line in ipairs(canonical_lines) do
    check_equal(runtime.canonical_json(json.decode(line)), line,
      "canonical JSONL line " .. index)
  end
  local validator = read_object(
    "capability_conformance/mcp_semantic_transport/validator_cases.json")
  check_equal(#validator.mutation_order, 76, "transport validator mutation count")
  local transport = read_object("capability_conformance/mcp_semantic_transport_contract.json")
  check_equal(transport.contract_id, "linkedspec-mcp-transport-v1", "transport identity")
  check_equal(transport.protocol_version, "2026-07-28", "protocol version")
end)

admission_role(roles_seen, "canonical_static_dispatch", function()
  local server = linkedspec.mcp_server()
  for _, row in ipairs({
    { "discover_request", "discover_response_lua", false },
    { "tools_list_request", "tools_list_response_perl", true },
    { "unsupported_version_request", "unsupported_version_response", false },
    { "missing_metadata_request", "missing_metadata_response", false },
    { "legacy_initialize_request", "legacy_initialize_response", false },
    { "unknown_method_request", "unknown_method_response", false },
    { "unknown_tool_request", "unknown_tool_response", false },
    { "malformed_arguments_request", "malformed_arguments_response", false },
  }) do
    local expected = frame(row[2])
    if row[3] then with_lua_identity(expected) end
    check_same_json(server:dispatch(frame(row[1]), "static-principal"), expected,
      row[1] .. " canonical classification")
  end
  check_equal(server:dispatch(frame("legacy_initialized_notification"), "static-principal"),
    nil, "legacy notification remains silent")
  check_equal(server:shutdown(), true, "static server shuts down")
end)

admission_role(roles_seen, "native_capabilities_identity", function()
  local native = linkedspec.semantic_query_to_json(graph_index:capabilities())
  local server = linkedspec.mcp_server()
  local handle = server:register_index(graph_index, "capabilities-principal")
  local actual = server:dispatch(with_handle(frame("capabilities_call_request"), handle),
    "capabilities-principal")
  check_same_json(actual, with_lua_identity(frame("capabilities_call_response")),
    "capabilities MCP response is exact")
  check_same_json(actual.result.structuredContent, native,
    "capabilities structured content equals native bytes")
  check_same_json(json.decode(actual.result.content[1].text), native,
    "capabilities text content equals native bytes")
  server:shutdown()
end)

admission_role(roles_seen, "native_query_identity", function()
  local server = linkedspec.mcp_server()
  local handle = server:register_index(graph_index, "query-principal")
  local request = with_handle(frame("query_call_request"), handle)
  local native = linkedspec.semantic_query_to_json(
    graph_index:query_neutral(clone(request.params.arguments.request)))
  local actual = server:dispatch(request, "query-principal")
  check_same_json(actual, with_lua_identity(frame("query_call_response")),
    "query MCP response is exact")
  check_same_json(actual.result.structuredContent, native,
    "query structured content equals native bytes")
  check_same_json(json.decode(actual.result.content[1].text), native,
    "query text content equals native bytes")
  server:shutdown()
end)

admission_role(roles_seen, "raw_input_outcomes", function()
  for _, row in ipairs(corpus.raw_inputs) do
    local output, log, input_stream_value, output_stream_value, log_stream_value =
      run_stdio(raw_fixture(row), { authorization = "raw-principal" })
    local expected
    if row.id == "valid_crlf_discovery" then
      local response = frame("discover_response_lua")
      response.id = 1
      expected = frame_bytes(response)
    else
      expected = error_bytes(row.expected.code, row.expected.message)
    end
    check_equal(output, expected, row.id .. " raw outcome")
    check_equal(log, "", row.id .. " remains operationally silent")
    check(not input_stream_value.closed and not output_stream_value.closed and
      not log_stream_value.closed, row.id .. " streams remain caller-owned")
  end
end)

admission_role(roles_seen, "lifecycle_outcomes", function()
  check_equal(#corpus.lifecycle_cases, 10, "lifecycle case count")
  check_equal(corpus.lifecycle_cases[1].expected, "dispatch_without_handshake",
    "ready state requires no handshake")

  local ready, ready_log = run_stdio(frame_bytes(frame("discover_request")),
    { authorization = "ready-principal" })
  check_equal(ready, frame_bytes(frame("discover_response_lua")),
    "ready stream dispatch is exact")
  check_equal(ready:find("\r", 1, true), nil, "canonical output uses LF only")
  check_equal(ready_log, "", "ready stream is silent")

  local unknown_cancel = run_stdio(frame_bytes(frame("cancelled_notification")),
    { authorization = "cancel-principal" })
  check_equal(unknown_cancel, "", "unknown cancellation is silent")

  local request = frame("discover_request")
  local cancellation = frame("cancelled_notification")
  cancellation.params.requestId = request.id
  local late_cancel = run_stdio(frame_bytes(request) .. frame_bytes(cancellation),
    { authorization = "cancel-principal" })
  check_equal(late_cancel, frame_bytes(frame("discover_response_lua")),
    "late cancellation cannot retract output")

  local legacy = run_stdio(frame_bytes(frame("legacy_initialized_notification")),
    { authorization = "legacy-principal" })
  check_equal(legacy, "", "legacy initialized notification is silent")

  local transport = read_object("capability_conformance/mcp_semantic_transport_contract.json")
  local maximum = transport.handle_registry.default_maximum_live_handles
  local capacity = linkedspec.mcp_server()
  capacity:register_index(graph_index, "capacity-principal",
    linkedspec.mcp_registration_options({ lifetime_ms = 1 }))
  wait_cpu(0.01)
  for _ = 1, maximum do capacity:register_index(graph_index, "capacity-principal") end
  expect_mcp_error(function()
    capacity:register_index(graph_index, "capacity-principal")
  end, "linkedspec_mcp_registry_full", "production registry capacity")
  capacity:shutdown()

  local graceful = linkedspec.mcp_server()
  graceful:register_index(graph_index, "eof-principal")
  local graceful_output = output_stream()
  graceful:serve_stdio(input_stream(""), graceful_output, "eof-principal")
  check_equal(graceful_output.flushes, 0, "clean EOF performs no output flush")
  expect_mcp_error(function()
    graceful:register_index(graph_index, "eof-principal")
  end, "linkedspec_mcp_server_shutdown", "graceful EOF shutdown")

  local failure_output = output_stream()
  local failure_log = output_stream()
  expect_mcp_error(function()
    linkedspec.mcp_server():serve_stdio(input_stream("", 0), failure_output,
      "failure-principal", { log = failure_log })
  end, "linkedspec_mcp_io_failure", "unexpected input failure")
  check_equal(failure_output:value(), "", "input failure emits no protocol bytes")
  check_equal(failure_log:value(), IO_LOG, "input failure emits fixed diagnostic")
end)

admission_role(roles_seen, "handle_state_indistinguishability", function()
  local expected = with_lua_identity(frame("handle_unavailable_response"))

  local unknown = linkedspec.mcp_server()
  check_same_json(unknown:dispatch(frame("handle_unavailable_request"), "state-principal"),
    expected, "unknown handle is unavailable")
  unknown:shutdown()

  local expired = linkedspec.mcp_server()
  local expired_handle = expired:register_index(graph_index, "state-principal",
    linkedspec.mcp_registration_options({ lifetime_ms = 1 }))
  wait_cpu(0.01)
  check_same_json(expired:dispatch(with_handle(frame("handle_unavailable_request"),
    expired_handle), "state-principal"), expected, "expired handle is unavailable")
  expired:shutdown()

  local revoked = linkedspec.mcp_server()
  local revoked_handle = revoked:register_index(graph_index, "state-principal")
  revoked:revoke_handle(revoked_handle)
  check_same_json(revoked:dispatch(with_handle(frame("handle_unavailable_request"),
    revoked_handle), "state-principal"), expected, "revoked handle is unavailable")
  revoked:shutdown()

  local unauthorized = linkedspec.mcp_server()
  local unauthorized_handle = unauthorized:register_index(graph_index, "state-principal")
  check_same_json(unauthorized:dispatch(with_handle(frame("handle_unavailable_request"),
    unauthorized_handle), "wrong-principal"), expected,
    "unauthorized handle is unavailable")
  unauthorized:shutdown()
end)

admission_role(roles_seen, "policy_overlay", function()
  local server = linkedspec.mcp_server()
  local default_handle = server:register_index(graph_index, "default-policy-principal")
  check_same_json(server:dispatch(with_handle(frame("capabilities_call_request"),
    default_handle), "default-policy-principal"),
    with_lua_identity(frame("capabilities_call_response")),
    "default capabilities identity")
  check_same_json(server:dispatch(with_handle(frame("query_call_request"), default_handle),
    "default-policy-principal"), with_lua_identity(frame("query_call_response")),
    "default query identity")

  local restricted = server:register_index(graph_index, "restricted-policy-principal",
    linkedspec.mcp_registration_options({
      policy = linkedspec.mcp_deployment_policy({
        source_detail_ceiling = "identity",
        page_max = 50,
        budget_maxima = linkedspec.mcp_budget_limits({
          max_records = 100, max_relations = 200, max_depth = 2,
        }),
      }),
    }))
  check_same_json(server:dispatch(with_handle(frame("restricted_capabilities_request"),
    restricted), "restricted-policy-principal"),
    with_lua_identity(frame("restricted_capabilities_response")),
    "restricted capability projection")
  check_same_json(server:dispatch(with_handle(frame("policy_denied_request"), restricted),
    "restricted-policy-principal"), with_lua_identity(frame("policy_denied_response")),
    "above-policy denial")
  server:shutdown()
end)

admission_role(roles_seen, "cancellation_emission", function()
  local before = find_row(corpus.lifecycle_cases, "id", "cancel_before_response_emission")
  check_equal(before.expected, "stop_and_suppress_response",
    "pre-emission cancellation contract")
  local focused = read_file("lua/test/mcp_server_lua_stdio_test.lua")
  check(focused:find("before_wire_emit =", 1, true) ~= nil,
    "focused proof owns pre-emission seam")
  check(focused:find("cancelled prepared response is suppressed", 1, true) ~= nil,
    "focused proof suppresses prepared output")
  check(focused:find("skip", 1, true) == nil, "focused stdio proof is not skipped")

  local request = frame("discover_request")
  local cancellation = frame("cancelled_notification")
  cancellation.params.requestId = request.id
  local output, log = run_stdio(frame_bytes(request) .. frame_bytes(cancellation),
    { authorization = "emission-principal" })
  check_equal(output, frame_bytes(frame("discover_response_lua")),
    "successful flush makes response final")
  check_equal(log, "", "successful emission is silent")
end)

admission_role(roles_seen, "shutdown_and_io", function()
  local complete = frame_bytes(frame("discover_request"))
  local later = linkedspec.mcp_server()
  local later_output = output_stream()
  local later_log = output_stream()
  expect_mcp_error(function()
    later:serve_stdio(input_stream(complete, #complete), later_output,
      "later-failure-principal", { log = later_log })
  end, "linkedspec_mcp_io_failure", "later input failure")
  check_equal(later_output:value(), frame_bytes(frame("discover_response_lua")),
    "prior flushed response survives later input failure")
  check_equal(later_log:value(), IO_LOG, "later failure emits fixed diagnostic")
  check(not later_output.closed and not later_log.closed,
    "later-failure streams remain caller-owned")

  local output_failure = linkedspec.mcp_server()
  output_failure:register_index(graph_index, "write-failure-principal")
  local output_log = output_stream()
  expect_mcp_error(function()
    output_failure:serve_stdio(input_stream(complete),
      output_stream({ fail_write = true }), "write-failure-principal", { log = output_log })
  end, "linkedspec_mcp_io_failure", "output write failure")
  check_equal(output_log:value(), IO_LOG, "output failure emits fixed diagnostic")
  expect_mcp_error(function()
    output_failure:register_index(graph_index, "write-failure-principal")
  end, "linkedspec_mcp_server_shutdown", "output failure releases and shuts down")
end)

admission_role(roles_seen, "hostile_output_and_log_privacy", function()
  local output = output_stream()
  local log = output_stream()
  local failure = expect_mcp_error(function()
    linkedspec.mcp_server():serve_stdio(input_stream("", 0), output,
      "hostile-principal", { log = log })
  end, "linkedspec_mcp_io_failure", "hostile input privacy")
  check_equal(output:value(), "", "hostile input emits no protocol bytes")
  check_equal(log:value(), IO_LOG, "hostile input log is fixed")
  local exposed = output:value() .. log:value() .. tostring(failure)
  for _, forbidden in ipairs({ "private/", "secret", "handle=", "auth=", "principal" }) do
    check(exposed:find(forbidden, 1, true) == nil,
      "hostile failure omits " .. forbidden)
  end

  local native_focused = read_file("lua/test/mcp_server_lua_dispatch_test.lua")
  check(native_focused:find("native exception is sanitized", 1, true) ~= nil,
    "focused proof owns injected native failure")
  check(native_focused:find('mode = "throw"', 1, true) ~= nil,
    "focused proof executes injected native failure")
  check(native_focused:find("skip", 1, true) == nil,
    "focused decoded proof is not skipped")
end)

admission_role(roles_seen, "authority_surface_fences", function()
  local production = table.concat({
    read_file("lua/src/linkedspec/mcp_contract_runtime.lua"),
    read_file("lua/src/linkedspec/mcp_server.lua"),
    read_file("lua/src/linkedspec/mcp_wire.lua"),
  }, "\n")
  for _, token in ipairs({
    "io.open(", "io.input(", "io.output(", "io.popen(", "io.lines(", "io.write(",
    "os.", "dofile(", "loadfile(", "package.", "debug.", "socket", "http", "ffi",
    "jit.", "LINKEDSPEC_TRACE_LEVEL", "parse_spec(", "compile_spec(", "load_spec(",
    "emit_lua_source",
  }) do
    check(production:find(token, 1, true) == nil,
      "production authority forbids " .. token)
  end

  local native = read_file("lua/native/mcp_system.c")
  for _, token in ipairs({ "/dev/urandom", "CLOCK_REALTIME" }) do
    check(native:find(token, 1, true) == nil, "native authority forbids " .. token)
  end
  for _, name in ipairs({ "fopen", "open", "system", "exec", "fork", "socket", "getenv" }) do
    check(native:find("%f[%w_]" .. name .. "%s*%(") == nil,
      "native authority forbids function call " .. name)
  end
  for _, token in ipairs({ "arc4random_buf", "getrandom", "CLOCK_MONOTONIC" }) do
    check(native:find(token, 1, true) ~= nil, "native system seam retains " .. token)
  end

  local server = linkedspec.mcp_server()
  for _, method in ipairs({ "register_index", "revoke_handle", "dispatch", "serve_stdio", "shutdown" }) do
    check_equal(type(server[method]), "function", "protected server exports " .. method)
  end
  check_equal(getmetatable(server), "protected", "server surface is protected")
  check_equal(next(server), nil, "server exposes no registry fields")
  server:shutdown()
  check_equal(linkedspec._server_for_testing, nil, "root omits private constructor")
  check_equal(linkedspec._registered_handles, nil, "root omits private registry inspection")
  local primary = read_file("lua/src/linkedspec/primary_cli.lua")
  check_equal(primary:find("mcp_server", 1, true), nil,
    "primary CLI has no MCP server bootstrap")
  check_equal(primary:find("serve_stdio", 1, true), nil,
    "primary CLI has no MCP stdio bootstrap")
end)

check_same_json(roles_seen, ROLE_ORDER, "all exact admission roles execute once in order")

if #failures > 0 then
  io.stderr:write("Lua MCP admission failures:\n")
  for index = 1, #failures do io.stderr:write(" - " .. failures[index] .. "\n") end
  os.exit(1)
end

io.write("[lua-mcp-admission] PASS: " .. assertions ..
  " assertions across all twelve exact roles\n")
