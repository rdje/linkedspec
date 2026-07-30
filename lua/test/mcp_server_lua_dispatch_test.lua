-- FUTURE-PARITY-BACKLOG.10.9.6.1 — protected Lua decoded MCP server proof.

local linkedspec = require("linkedspec")
assert(package.loaded["linkedspec.mcp_server"] == nil,
  "root package must lazily load the MCP implementation")

local json = linkedspec.json
local mcp = require("linkedspec.mcp_server")
local runtime = require("linkedspec.mcp_contract_runtime")

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

local function expect_mcp_error(operation, code, label)
  local ok, value = pcall(operation)
  check_equal(ok, false, label .. " rejected")
  if ok then return nil end
  check(linkedspec.is_mcp_server_error(value), label .. " returns typed MCP error")
  if linkedspec.is_mcp_server_error(value) then
    check_equal(value.code, code, label .. " error code")
    check_equal(getmetatable(value), "protected", label .. " protected error")
    local encoded = linkedspec.mcp_server_error_to_json(value)
    check_equal(encoded.code, code, label .. " serialized error code")
    check(type(encoded.message) == "string" and encoded.message ~= "", label .. " error message")
  end
  return value
end

local function clone(value)
  return runtime.clone_data(value)
end

local function frame(id)
  return assert(runtime.frame(id))
end

local function with_handle(value, handle)
  value.params.arguments.handle = handle
  return value
end

local function with_lua_identity(value)
  value.result._meta["io.modelcontextprotocol/serverInfo"].name = mcp.SERVER_NAME
  return value
end

local function entropy_sequence(start)
  local value = start
  return function()
    local result = string.rep(string.char(value), 32)
    value = value + 1
    return result
  end
end

local clock = { value = 0 }
local function test_server(start, options)
  options = options or {}
  return mcp._server_for_testing({
    entropy = options.entropy or entropy_sequence(start),
    now_ms = options.now_ms or function() return clock.value end,
    maximum_handles = options.maximum_handles,
    handle_attempts = options.handle_attempts,
    capabilities_of = options.capabilities_of,
    query_index = options.query_index,
  })
end

local function graph_index_with_detail(detail)
  return linkedspec.semantic_index(read_file(
    "capability_conformance/semantic_introspection/graph.spec"
  ), {
    logical_name = "graph.spec",
    source_detail_ceiling = detail,
  })
end

local graph_index = graph_index_with_detail("text")

-- Public static decoded classifications and request immutability.
do
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
    local request = frame(row[1])
    local before = json.encode(request)
    local expected = frame(row[2])
    if row[3] then with_lua_identity(expected) end
    check_same_json(server:dispatch(request, "static-principal"), expected,
      row[1] .. " classification")
    check_equal(json.encode(request), before, row[1] .. " caller request remains detached")
  end
  check_equal(server:dispatch(frame("legacy_initialized_notification"), "static-principal"), nil,
    "legacy notification is ignored")
  check_equal(server:dispatch(json.harray({
    jsonrpc = "2.0", method = "notifications/host_private",
  }), "static-principal"), nil, "unknown notification is ignored")
end

-- Registration retains the native index, dispatches fresh calls, and lowers policy only.
do
  local capability_calls = 0
  local query_calls = 0
  local server = test_server(0x20, {
    capabilities_of = function(index)
      check_equal(index, graph_index, "capabilities receives retained native index")
      capability_calls = capability_calls + 1
      return linkedspec.semantic_query_to_json(index:capabilities())
    end,
    query_index = function(index, request)
      check_equal(index, graph_index, "query receives retained native index")
      query_calls = query_calls + 1
      return linkedspec.semantic_query_to_json(index:query_neutral(request))
    end,
  })
  local handle = server:register_index(graph_index, "native-principal")
  check(#handle == 43 and handle:match("^[A-Za-z0-9_-]+$") ~= nil,
    "registered handle is exact unpadded base64url")
  check_equal(capability_calls, 1, "registration validates capabilities once")

  local capabilities = with_handle(frame("capabilities_call_request"), handle)
  local before = json.encode(capabilities)
  check_same_json(server:dispatch(capabilities, "native-principal"),
    with_lua_identity(frame("capabilities_call_response")),
    "capabilities response is exact")
  check_equal(capability_calls, 2, "capabilities remains a fresh native call")
  check_equal(json.encode(capabilities), before, "capabilities request remains detached")

  local query = with_handle(frame("query_call_request"), handle)
  before = json.encode(query)
  check_same_json(server:dispatch(query, "native-principal"),
    with_lua_identity(frame("query_call_response")), "query response is exact")
  check_equal(query_calls, 1, "query calls native evaluator once")
  check_equal(json.encode(query), before, "query request remains detached")

  local semantic_failure = with_handle(frame("semantic_ok_false_request"), handle)
  check_same_json(server:dispatch(semantic_failure, "native-principal"),
    with_lua_identity(frame("semantic_ok_false_response")),
    "semantic ok-false remains a successful MCP tool result")
  check_equal(query_calls, 2, "semantic ok-false calls native evaluator")

  local restricted = server:register_index(graph_index, "restricted-principal",
    linkedspec.mcp_registration_options({
      policy = linkedspec.mcp_deployment_policy({
        source_detail_ceiling = "identity",
        page_max = 50,
        budget_maxima = linkedspec.mcp_budget_limits({
          max_records = 100,
          max_relations = 200,
          max_depth = 2,
        }),
      }),
    }))
  check_same_json(server:dispatch(with_handle(
    frame("restricted_capabilities_request"), restricted), "restricted-principal"),
    with_lua_identity(frame("restricted_capabilities_response")),
    "restricted capabilities are exact")
  local before_denied = query_calls
  check_same_json(server:dispatch(with_handle(frame("policy_denied_request"), restricted),
    "restricted-principal"), with_lua_identity(frame("policy_denied_response")),
    "contract policy denial is exact")
  check_equal(query_calls, before_denied, "policy denial precedes native query")

  local allowed = with_handle(frame("query_call_request"), restricted)
  local request = allowed.params.arguments.request
  request.page.limit = 50
  request.budget.max_records = 100
  request.budget.max_relations = 200
  request.budget.max_depth = 2
  local denied = {}
  local source_denied = clone(allowed)
  source_denied.params.arguments.request.source.detail = "span"
  denied[#denied + 1] = source_denied
  local digest_denied = clone(allowed)
  digest_denied.params.arguments.request.source.include_content_digest = true
  denied[#denied + 1] = digest_denied
  local page_denied = clone(allowed)
  page_denied.params.arguments.request.page.limit = 51
  denied[#denied + 1] = page_denied
  for _, row in ipairs({
    { "max_records", 101 }, { "max_relations", 201 }, { "max_depth", 3 },
  }) do
    local value = clone(allowed)
    value.params.arguments.request.budget[row[1]] = row[2]
    denied[#denied + 1] = value
  end
  local policy_for_eight = with_lua_identity(frame("policy_denied_response"))
  policy_for_eight.id = 8
  for index = 1, #denied do
    local count = query_calls
    check_same_json(server:dispatch(denied[index], "restricted-principal"), policy_for_eight,
      "policy denial family " .. index)
    check_equal(query_calls, count, "policy denial family bypasses native query " .. index)
  end

  for index, policy in ipairs({
    linkedspec.mcp_deployment_policy({ page_max = 1001 }),
    linkedspec.mcp_deployment_policy({ budget_maxima = linkedspec.mcp_budget_limits({
      max_records = 10001, max_relations = 2000, max_depth = 4,
    }) }),
  }) do
    expect_mcp_error(function()
      server:register_index(graph_index, "invalid-policy",
        linkedspec.mcp_registration_options({ policy = policy }))
    end, "linkedspec_mcp_invalid_policy", "elevating policy " .. index)
  end
end

-- Omitted and unrelated partial overlays retain native portable diagnostic authority.
do
  local identity_index = graph_index_with_detail("identity")
  local query_calls = 0
  local server = test_server(0x2a, {
    capabilities_of = function(index)
      return linkedspec.semantic_query_to_json(index:capabilities())
    end,
    query_index = function(index, request)
      query_calls = query_calls + 1
      return linkedspec.semantic_query_to_json(index:query_neutral(request))
    end,
  })
  local default_handle = server:register_index(identity_index, "default-policy-principal")
  local source_request = with_handle(frame("query_call_request"), default_handle)
  source_request.params.arguments.request.source.detail = "span"
  local source_response = server:dispatch(source_request, "default-policy-principal")
  check_equal(source_response.result.structuredContent.diagnostics[1].code,
    "semantic_query_source_detail_forbidden",
    "omitted source overlay preserves native source-ceiling diagnostic")
  check_equal(query_calls, 1, "default source ceiling dispatches one native query")

  local unsupported = with_handle(frame("query_call_request"), default_handle)
  unsupported.params.arguments.request.contract = "linkedspec-semantic-query-v2"
  local unsupported_response = server:dispatch(unsupported, "default-policy-principal")
  check_equal(unsupported_response.result.structuredContent.diagnostics[1].code,
    "semantic_query_contract_unsupported",
    "bounded future contract reaches native portable diagnostic")
  check_equal(query_calls, 2, "unsupported contract dispatches one native query")

  local partial_handle = server:register_index(identity_index, "partial-policy-principal",
    linkedspec.mcp_registration_options({
      policy = linkedspec.mcp_deployment_policy({ page_max = 50 }),
    }))
  local partial_request = with_handle(frame("query_call_request"), partial_handle)
  partial_request.params.arguments.request.page.limit = 50
  partial_request.params.arguments.request.source.detail = "span"
  local partial_response = server:dispatch(partial_request, "partial-policy-principal")
  check_equal(partial_response.result.structuredContent.diagnostics[1].code,
    "semantic_query_source_detail_forbidden",
    "page-only overlay does not preempt native source diagnostic")
  check_equal(query_calls, 3, "partial unrelated overlay dispatches one native query")
end

-- Unknown, unauthorized, expired, revoked, capacity, and shutdown states.
do
  local expected = with_lua_identity(frame("handle_unavailable_response"))
  local unknown = test_server(0x30)
  check_same_json(unknown:dispatch(frame("handle_unavailable_request"), "principal"), expected,
    "unknown handle is unavailable")

  local unauthorized = test_server(0x31)
  local unauthorized_handle = unauthorized:register_index(graph_index, "principal")
  check_same_json(unauthorized:dispatch(with_handle(
    frame("handle_unavailable_request"), unauthorized_handle), "wrong"), expected,
    "unauthorized handle is indistinguishable")

  clock.value = 1000
  local expired = test_server(0x32)
  local expired_handle = expired:register_index(graph_index, "principal",
    linkedspec.mcp_registration_options({ lifetime_ms = 1 }))
  clock.value = 1001
  check_same_json(expired:dispatch(with_handle(
    frame("handle_unavailable_request"), expired_handle), "principal"), expected,
    "expired handle is indistinguishable")

  clock.value = 0
  local revoked = test_server(0x33)
  local revoked_handle = revoked:register_index(graph_index, "principal")
  check(revoked:revoke_handle(revoked_handle), "revoke succeeds")
  check(revoked:revoke_handle(revoked_handle), "repeat revoke is idempotent")
  check_same_json(revoked:dispatch(with_handle(
    frame("handle_unavailable_request"), revoked_handle), "principal"), expected,
    "revoked handle is indistinguishable")
  expect_mcp_error(function() revoked:revoke_handle("invalid") end,
    "linkedspec_mcp_invalid_handle", "invalid handle")
  for index, authorization in ipairs({ "", string.rep("x", 4097), true }) do
    expect_mcp_error(function() revoked:register_index(graph_index, authorization) end,
      "linkedspec_mcp_invalid_authorization", "invalid authorization " .. index)
  end
  for index, lifetime in ipairs({ 0, 86400001 }) do
    expect_mcp_error(function()
      revoked:register_index(graph_index, "principal",
        linkedspec.mcp_registration_options({ lifetime_ms = lifetime }))
    end, "linkedspec_mcp_invalid_registration", "invalid lifetime " .. index)
  end

  local capacity_clock = { value = 2000 }
  local capacity = test_server(0x34, {
    now_ms = function() return capacity_clock.value end,
    maximum_handles = 1,
  })
  capacity:register_index(graph_index, "principal",
    linkedspec.mcp_registration_options({ lifetime_ms = 1 }))
  expect_mcp_error(function() capacity:register_index(graph_index, "principal") end,
    "linkedspec_mcp_registry_full", "registry capacity")
  capacity_clock.value = 2001
  check(#capacity:register_index(graph_index, "principal") == 43,
    "expired entry is pruned before capacity failure")
  check_equal(mcp._registered_handles(capacity), 1, "registry retains one live handle")
  check(capacity:shutdown(), "shutdown succeeds")
  check(capacity:shutdown(), "shutdown is idempotent")
  check_equal(mcp._registered_handles(capacity), 0, "shutdown releases indexes")
  check_equal(capacity:dispatch(frame("discover_request"), "principal").error.code, -32603,
    "dispatch after shutdown is sanitized")
  expect_mcp_error(function() capacity:register_index(graph_index, "principal") end,
    "linkedspec_mcp_server_shutdown", "registration after shutdown")
end

-- Entropy, clock, collision, native failure, and cancellation boundaries.
do
  local short = test_server(0x40, { entropy = function() return string.rep("x", 31) end })
  expect_mcp_error(function() short:register_index(graph_index, "principal") end,
    "linkedspec_mcp_entropy_failure", "short entropy")

  local bad_clock = test_server(0x41, {
    now_ms = function() error("host path /private/secret", 0) end,
  })
  local clock_error = expect_mcp_error(function()
    bad_clock:register_index(graph_index, "principal")
  end, "linkedspec_mcp_clock_failure", "hostile clock")
  check(tostring(clock_error):find("private", 1, true) == nil,
    "clock error does not leak host path")

  local collision = test_server(0x42, {
    entropy = function() return string.rep("z", 32) end,
    maximum_handles = 2,
    handle_attempts = 2,
  })
  collision:register_index(graph_index, "principal")
  expect_mcp_error(function() collision:register_index(graph_index, "principal") end,
    "linkedspec_mcp_entropy_failure", "bounded handle collision")

  local overflow = test_server(0x43, { now_ms = function() return 9007199254740991 end })
  expect_mcp_error(function() overflow:register_index(graph_index, "principal") end,
    "linkedspec_mcp_clock_failure", "expiry overflow")

  local invalid_index = test_server(0x44, {
    capabilities_of = function() return json.harray({ host_private = true }) end,
  })
  expect_mcp_error(function() invalid_index:register_index(graph_index, "principal") end,
    "linkedspec_mcp_invalid_index", "invalid native capabilities")
  expect_mcp_error(function()
    invalid_index:register_index({}, "principal")
  end, "linkedspec_mcp_invalid_index", "forged semantic index")

  local mode = "normal"
  local server
  server = test_server(0x45, {
    capabilities_of = function(index)
      if mode == "throw" then error("host secret /private/path", 0) end
      if mode == "invalid" then return json.harray({ host_private = true }) end
      if mode == "cancel" then
        local cancel = frame("cancelled_notification")
        cancel.params.requestId = 7
        server:dispatch(cancel, "principal")
      end
      return linkedspec.semantic_query_to_json(index:capabilities())
    end,
  })
  local handle = server:register_index(graph_index, "principal")
  local request = with_handle(frame("capabilities_call_request"), handle)
  local internal = frame("sanitized_internal_error_response")
  internal.id = 7
  mode = "throw"
  local response = server:dispatch(request, "principal")
  check_same_json(response, internal, "native exception is sanitized")
  check(json.encode(response):find("private/path", 1, true) == nil,
    "native exception path is absent")
  mode = "invalid"
  check_same_json(server:dispatch(request, "principal"), internal,
    "invalid native response is sanitized")
  mode = "cancel"
  check_equal(server:dispatch(request, "principal"), nil,
    "in-flight cancellation suppresses decoded response")
  check_equal(mcp._active_requests(server), 0, "cancelled request state is released")
  mode = "normal"
  local completed = server:dispatch(request, "principal")
  check_same_json(completed, with_lua_identity(frame("capabilities_call_response")),
    "request completes after cancellation case")
  local late = frame("cancelled_notification")
  late.params.requestId = 7
  check_equal(server:dispatch(late, "principal"), nil, "late cancellation is inert")
  check_same_json(completed, with_lua_identity(frame("capabilities_call_response")),
    "late cancellation cannot mutate completed response")
end

-- Public opacity, production system functions, and authority fences.
do
  local budget = linkedspec.mcp_budget_limits({
    max_records = 1, max_relations = 2, max_depth = 3,
  })
  local policy = linkedspec.mcp_deployment_policy({ budget_maxima = budget })
  local options = linkedspec.mcp_registration_options({ policy = policy, lifetime_ms = 100 })
  check_equal(getmetatable(budget), "protected", "budget is protected")
  check_equal(getmetatable(policy), "protected", "policy is protected")
  check_equal(getmetatable(options), "protected", "registration options are protected")
  check(not pcall(function() budget.max_records = 2 end), "budget is immutable")
  check_equal(budget.max_records, 1, "budget exposes copied scalar")
  local server = linkedspec.mcp_server()
  check_equal(getmetatable(server), "protected", "server metatable is protected")
  check_equal(next(server), nil, "server exposes no registry fields")
  check_equal(tostring(server), "McpServer(stopped=false)", "server string is sanitized")
  local handle = server:register_index(graph_index, "production-principal")
  check(#handle == 43 and handle:match("^[A-Za-z0-9_-]+$") ~= nil,
    "production system seam generates a valid handle")

  for _, name in ipairs({
    "mcp_server", "mcp_budget_limits", "mcp_deployment_policy",
    "mcp_registration_options", "is_mcp_server_error", "mcp_server_error_to_json",
  }) do
    check_equal(type(linkedspec[name]), "function", "root exports " .. name)
  end
  check_equal(linkedspec._server_for_testing, nil, "root omits private test constructor")
  check_equal(linkedspec._registered_handles, nil, "root omits registry inspection")

  local production = table.concat({
    read_file("lua/src/linkedspec/mcp_contract_runtime.lua"),
    read_file("lua/src/linkedspec/mcp_server.lua"),
  }, "\n")
  for _, token in ipairs({
    "io.open", "io.popen", "os.execute", "dofile", "loadfile", "package.loadlib", "parse_spec",
    "compile_spec", "load_spec", "runtime_execute", "LINKEDSPEC_TRACE_LEVEL",
    "emit_lua_source", "socket", "http", "coroutine", "capability_conformance/",
  }) do
    check_equal(production:find(token, 1, true), nil,
      "production Lua MCP authority forbids " .. token)
  end
  local native = read_file("lua/native/mcp_system.c")
  for _, token in ipairs({ "/dev/urandom", "fopen", "open(", "rand(", "CLOCK_REALTIME" }) do
    check_equal(native:find(token, 1, true), nil, "native system seam forbids " .. token)
  end
  check(native:find("arc4random_buf", 1, true) ~= nil, "native system seam owns BSD entropy")
  check(native:find("getrandom", 1, true) ~= nil, "native system seam owns Linux entropy")
  check(native:find("CLOCK_MONOTONIC", 1, true) ~= nil, "native system seam owns monotonic time")
  local primary = read_file("lua/src/linkedspec/primary_cli.lua")
  check_equal(primary:find("mcp_server", 1, true), nil, "primary CLI has no MCP bootstrap")
end

if #failures > 0 then
  io.stderr:write("Lua MCP decoded-server failures:\n")
  for index = 1, #failures do io.stderr:write(" - " .. failures[index] .. "\n") end
  os.exit(1)
end

io.write("[lua-mcp-dispatch] PASS: " .. assertions ..
  " public, registry, dispatch, policy, lifecycle, security, and authority assertions\n")
