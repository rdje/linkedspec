-- FUTURE-PARITY-BACKLOG.10.9.6.2 — shared dual-ABI Lua MCP strict stdio proof.

local linkedspec = require("linkedspec")
local json = linkedspec.json
local mcp = require("linkedspec.mcp_server")
local runtime = require("linkedspec.mcp_contract_runtime")

assert(package.loaded["linkedspec.mcp_wire"] == nil,
  "decoded MCP loading must not eagerly load the private wire")

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

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
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

local function with_lua_identity(value)
  value.result._meta["io.modelcontextprotocol/serverInfo"].name = mcp.SERVER_NAME
  return value
end

local function with_handle(value, handle)
  value.params.arguments.handle = handle
  return value
end

local function entropy()
  return string.rep("Z", 32)
end

local function test_server(options)
  options = options or {}
  return mcp._server_for_testing({
    entropy = entropy,
    now_ms = function() return 10000 end,
    before_wire_emit = options.before_wire_emit,
  })
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
    error("private input path and authorization", 0)
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
  if self.fail_write then error("private output path, handle, and response", 0) end
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

local function output_for(bytes, server)
  local input = input_stream(bytes)
  local output = output_stream()
  local active_server = server or test_server()
  active_server:serve_stdio(input, output, "wire-principal")
  check_equal(input.closed, false, "input remains caller-owned")
  check_equal(output.closed, false, "output remains caller-owned")
  return output:value(), output
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

-- Every canonical raw-byte classification runs through the public method.
do
  local corpus = runtime.corpus()
  for _, row in ipairs(corpus.raw_inputs) do
    local server = test_server()
    local input = input_stream(raw_fixture(row))
    local output = output_stream()
    local log = output_stream()
    server:serve_stdio(input, output, "raw-principal", { log = log })
    local expected
    if row.id == "valid_crlf_discovery" then
      local response = frame("discover_response_lua")
      response.id = 1
      expected = frame_bytes(response)
    else
      expected = error_bytes(row.expected.code, row.expected.message)
    end
    check_equal(output:value(), expected, row.id .. " exact canonical classification")
    check_equal(log:value(), "", row.id .. " is operationally silent")
    check_equal(input.closed, false, row.id .. " input remains caller-owned")
    check_equal(output.closed, false, row.id .. " output remains caller-owned")
    check_equal(log.closed, false, row.id .. " log remains caller-owned")
    check_equal(mcp._registered_handles(server), 0, row.id .. " registry released")
    check_equal(mcp._active_requests(server), 0, row.id .. " requests released")
  end
  check(package.loaded["linkedspec.mcp_wire"] ~= nil,
    "public serve lazily loads the private wire")
end

-- Lexical identity, duplicate keys, depth, UTF-8 byte counts, and numeric kinds.
do
  local parse_error = error_bytes(-32700, "Parse error")
  local invalid_request = error_bytes(-32600, "Invalid Request")
  for index, text in ipairs({
    '{"\\u0069d":1,"id":2,"jsonrpc":"2.0","method":"server/discover","params":{}}\n',
    '{"id":1,"jsonrpc":"2.0","method":"server/discover","params":{"x":{"a":1,"\\u0061":2}}}\n',
    '{"id":"\\uD800","jsonrpc":"2.0","method":"server/discover","params":{}}\n',
    '{"id":NaN,"jsonrpc":"2.0","method":"server/discover","params":{}}\n',
    '{"id":1,"jsonrpc":"2.0","method":"server/discover","params":{"value":1e999}}\n',
    "\n",
  }) do
    local output = output_for(text)
    check_equal(output, parse_error, "lexical parse rejection " .. index)
  end

  local depth64 = string.rep("[", 64) .. "0" .. string.rep("]", 64) .. "\n"
  check_equal(output_for(depth64), invalid_request, "depth 64 is lexically admitted but root-rejected")

  local discover = frame("discover_request")
  local maximum = runtime.canonical_json(discover)
  maximum = maximum .. string.rep(" ", 1048576 - #maximum) .. "\r\n"
  check_equal(output_for(maximum), frame_bytes(frame("discover_response_lua")),
    "exact maximum frame plus CRLF is admitted")

  for _, id in ipairs({ "1.0", "1e0", "9007199254740992", "-9007199254740992", "null" }) do
    local request = '{"id":' .. id .. ',"jsonrpc":"2.0",' ..
      '"method":"server/discover","params":{}}\n'
    check_equal(output_for(request), invalid_request, "invalid lexical id " .. id)
  end
  for _, id in ipairs({ "-9007199254740991", "9007199254740991" }) do
    local request = '{"id":' .. id .. ',"jsonrpc":"2.0",' ..
      '"method":"server/discover","params":' .. runtime.canonical_json(discover.params) .. '}\n'
    local expected = frame("discover_response_lua")
    expected.id = tonumber(id)
    check_equal(output_for(request), frame_bytes(expected), "safe integer id " .. id)
  end

  for _, row in ipairs({ { 64, true }, { 65, false } }) do
    local id = string.rep("é", row[1])
    local request = frame("discover_request")
    request.id = id
    local output = output_for(frame_bytes(request))
    if row[2] then
      local expected = frame("discover_response_lua")
      expected.id = id
      check_equal(output, frame_bytes(expected), "128-byte string id is admitted")
      check(output:find(id, 1, true) ~= nil, "UTF-8 id remains literal")
      check(output:find("\\u00e9", 1, true) == nil, "UTF-8 id is not escaped")
    else
      check_equal(output, invalid_request, "over-128-byte string id is rejected")
    end
  end

  local metadata_fraction = frame("discover_request")
  metadata_fraction.params._meta.extra = json.harray({ ratio = 1.5 })
  check_equal(output_for(frame_bytes(metadata_fraction)),
    frame_bytes(frame("discover_response_lua")),
    "fractional values remain valid in unconstrained metadata")

  local invalid_params = frame("malformed_arguments_response")
  invalid_params.id = 8
  local query = runtime.canonical_json(frame("query_call_request"))
  for _, replacement in ipairs({
    { '"limit":100', '"limit":1.0', "page limit" },
    { '"max_depth":4', '"max_depth":4e0', "maximum depth" },
    { '"max_records":1000', '"max_records":1000.0', "maximum records" },
    { '"max_relations":2000', '"max_relations":2e3', "maximum relations" },
  }) do
    local changed, count = query:gsub(replacement[1], replacement[2], 1)
    check_equal(count, 1, replacement[3] .. " fixture replacement is exact")
    check_equal(output_for(changed .. "\n"), frame_bytes(invalid_params),
      replacement[3] .. " fraction remains invalid on both ABIs")
  end
  local cancellation = runtime.canonical_json(frame("cancelled_notification"))
  cancellation = assert(cancellation:gsub('"requestId":13', '"requestId":13.0', 1))
  check_equal(output_for(cancellation .. "\n"), "",
    "fractional cancellation id remains an invalid silent notification")
end

-- Framing recovery, exact native responses, final EOF, and cancellation-through-flush.
do
  local list = frame("tools_list_request")
  local expected_list = frame_bytes(with_lua_identity(frame("tools_list_response_perl")))
  check_equal(output_for("{\n" .. frame_bytes(list)),
    error_bytes(-32700, "Parse error") .. expected_list,
    "malformed frame recovers at the next LF")
  check_equal(output_for(string.rep("x", 1048577) .. "\n" .. frame_bytes(list)),
    error_bytes(-32700, "Parse error") .. expected_list,
    "overlong frame drains and recovers")
  check_equal(output_for(string.rep("x", 1048577)),
    error_bytes(-32700, "Parse error"), "overlong final EOF frame is rejected")

  local final_request = frame("discover_request")
  final_request.id = "réq"
  local final_expected = frame("discover_response_lua")
  final_expected.id = "réq"
  check_equal(output_for(runtime.canonical_json(final_request)), frame_bytes(final_expected),
    "complete final EOF frame is accepted")

  local graph_index = linkedspec.semantic_index(read_file(
    "capability_conformance/semantic_introspection/graph.spec"
  ), { logical_name = "graph.spec", source_detail_ceiling = "text" })
  local server = test_server()
  local handle = server:register_index(graph_index, "wire-principal")
  local wire = table.concat({
    frame_bytes(frame("discover_request")),
    frame_bytes(list),
    frame_bytes(with_handle(frame("capabilities_call_request"), handle)),
    frame_bytes(with_handle(frame("query_call_request"), handle)),
    frame_bytes(frame("legacy_initialized_notification")),
  })
  local output = output_stream()
  server:serve_stdio(input_stream(wire), output, "wire-principal")
  local expected = table.concat({
    frame_bytes(frame("discover_response_lua")),
    expected_list,
    frame_bytes(with_lua_identity(frame("capabilities_call_response"))),
    frame_bytes(with_lua_identity(frame("query_call_response"))),
  })
  check_equal(output:value(), expected, "mixed request sequence emits exact Lua frames")
  check_equal(output:value():find("\r", 1, true), nil, "canonical output uses LF only")
  check_equal(mcp._registered_handles(server), 0, "EOF releases retained index")
  check_equal(mcp._active_requests(server), 0, "EOF releases active requests")

  local authorization = "cancel-principal"
  local cancelled = false
  local cancellation_server = test_server({
    before_wire_emit = function(active_server, prepared)
      if prepared == nil or cancelled then return end
      cancelled = true
      local notification = frame("cancelled_notification")
      notification.params.requestId = json.decode(prepared)
      check_equal(active_server:dispatch(notification, authorization), nil,
        "pre-emission cancellation is accepted")
    end,
  })
  local cancellation_output = output_stream()
  cancellation_server:serve_stdio(input_stream(frame_bytes(frame("discover_request"))),
    cancellation_output, authorization)
  check(cancelled, "pre-emission callback ran")
  check_equal(cancellation_output:value(), "", "cancelled prepared response is suppressed")
  check_equal(mcp._active_requests(cancellation_server), 0,
    "cancelled prepared request is released")

  local late_request = frame("discover_request")
  local late_cancel = frame("cancelled_notification")
  late_cancel.params.requestId = late_request.id
  check_equal(output_for(frame_bytes(late_request) .. frame_bytes(late_cancel)),
    frame_bytes(frame("discover_response_lua")),
    "cancellation after successful flush cannot retract output")
end

-- EOF and hostile read/write/flush/log paths release state and expose fixed diagnostics only.
do
  local graph_index = linkedspec.semantic_index(read_file(
    "capability_conformance/semantic_introspection/graph.spec"
  ), { logical_name = "graph.spec", source_detail_ceiling = "text" })
  local clean = test_server()
  clean:register_index(graph_index, "clean-release-principal")
  local clean_input = input_stream("")
  local clean_output = output_stream()
  clean:serve_stdio(clean_input, clean_output, "clean-release-principal")
  check_equal(mcp._registered_handles(clean), 0, "clean EOF releases handles")
  check_equal(clean_output.flushes, 0, "clean EOF performs no unnecessary output flush")
  check_equal(clean_input.closed, false, "clean EOF leaves input open")
  check_equal(clean_output.closed, false, "clean EOF leaves output open")
  expect_mcp_error(function()
    clean:serve_stdio(input_stream(""), output_stream(), "clean-release-principal")
  end, "linkedspec_mcp_server_shutdown", "repeat serve after EOF")

  local input_failure = test_server()
  input_failure:register_index(graph_index, "input-private-principal")
  local input_output = output_stream()
  local input_log = output_stream()
  expect_mcp_error(function()
    input_failure:serve_stdio(input_stream("", 0), input_output,
      "input-private-principal", { log = input_log })
  end, "linkedspec_mcp_io_failure", "hostile input")
  check_equal(input_output:value(), "", "input failure emits no protocol bytes")
  check_equal(input_log:value(), "linkedspec_mcp_io_failure\n",
    "input failure emits fixed diagnostic")
  check_equal(mcp._registered_handles(input_failure), 0,
    "input failure releases handles")

  local discover_bytes = frame_bytes(frame("discover_request"))
  local later = test_server()
  local later_output = output_stream()
  local later_log = output_stream()
  expect_mcp_error(function()
    later:serve_stdio(input_stream(discover_bytes, #discover_bytes), later_output,
      "later-private-principal", { log = later_log })
  end, "linkedspec_mcp_io_failure", "later input failure")
  check_equal(later_output:value(), frame_bytes(frame("discover_response_lua")),
    "prior flushed response survives later input failure")
  check_equal(later_log:value(), "linkedspec_mcp_io_failure\n",
    "later failure emits fixed diagnostic")

  local output_failure = test_server()
  output_failure:register_index(graph_index, "output-private-principal")
  local output_log = output_stream()
  expect_mcp_error(function()
    output_failure:serve_stdio(input_stream(discover_bytes),
      output_stream({ fail_write = true }), "output-private-principal", { log = output_log })
  end, "linkedspec_mcp_io_failure", "hostile output")
  check_equal(output_log:value(), "linkedspec_mcp_io_failure\n",
    "output failure emits fixed diagnostic")
  check_equal(mcp._registered_handles(output_failure), 0,
    "output failure releases handles")
  for _, word in ipairs({
    "graph", "handle", "principal", "source", "request", "response",
    "path", "object", "exception",
  }) do
    check_equal(output_log:value():find(word, 1, true), nil,
      "diagnostic omits private word " .. word)
  end

  local flush_log = output_stream()
  expect_mcp_error(function()
    test_server():serve_stdio(input_stream(discover_bytes),
      output_stream({ fail_flush = true }), "flush-private-principal", { log = flush_log })
  end, "linkedspec_mcp_io_failure", "hostile flush")
  check_equal(flush_log:value(), "linkedspec_mcp_io_failure\n",
    "flush failure emits fixed diagnostic")

  expect_mcp_error(function()
    test_server():serve_stdio(input_stream("", 0), output_stream(), "principal",
      { log = output_stream({ fail_write = true }) })
  end, "linkedspec_mcp_io_failure", "hostile log preserves primary classification")

  local invalid = test_server()
  local unread = input_stream(discover_bytes)
  local same = output_stream()
  expect_mcp_error(function()
    invalid:serve_stdio(unread, same, "principal", { log = same })
  end, "linkedspec_mcp_invalid_stdio", "shared protocol/log stream")
  expect_mcp_error(function()
    invalid:serve_stdio(unread, output_stream(), "")
  end, "linkedspec_mcp_invalid_authorization", "invalid wire authorization")
  expect_mcp_error(function()
    invalid:serve_stdio(unread, output_stream(), "principal", { unknown = true })
  end, "linkedspec_mcp_invalid_stdio", "unsupported wire option")
  check_equal(unread.reads, 0, "invalid arguments are rejected before input consumption")
end

-- The public surface is narrow; production transport gains no unrelated authority.
do
  local server = test_server()
  check_equal(type(server.serve_stdio), "function", "protected server exports serve_stdio")
  check_equal(linkedspec.serve_stdio, nil, "root package exposes no static wire facade")
  check_equal(linkedspec._decode_payload, nil, "root package omits lexical proof seam")
  local production = table.concat({
    read_file("lua/src/linkedspec/mcp_contract_runtime.lua"),
    read_file("lua/src/linkedspec/mcp_server.lua"),
    read_file("lua/src/linkedspec/mcp_wire.lua"),
  }, "\n")
  for _, token in ipairs({
    "io.open", "io.popen", "os.execute", "dofile", "loadfile", "package.loadlib",
    "parse_spec", "compile_spec", "load_spec", "runtime_execute",
    "LINKEDSPEC_TRACE_LEVEL", "emit_lua_source", "socket", "http", "coroutine",
    "capability_conformance/",
  }) do
    check_equal(production:find(token, 1, true), nil,
      "production Lua MCP wire forbids " .. token)
  end
  local primary = read_file("lua/src/linkedspec/primary_cli.lua")
  check_equal(primary:find("serve_stdio", 1, true), nil,
    "primary CLI has no MCP wire bootstrap")
end

if #failures > 0 then
  io.stderr:write("Lua MCP strict-stdio failures:\n")
  for index = 1, #failures do io.stderr:write(" - " .. failures[index] .. "\n") end
  os.exit(1)
end

io.write("[lua-mcp-stdio] PASS: " .. assertions ..
  " framing, lexical, canonical, cancellation, lifecycle, and authority assertions\n")
