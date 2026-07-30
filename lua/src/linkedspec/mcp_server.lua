-- Protected in-process Lua MCP registry and decoded request dispatcher.

local json = require("linkedspec.json")
local runtime = require("linkedspec.mcp_contract_runtime")
local semantic_index = require("linkedspec.semantic_index")
local semantic_query = require("linkedspec.semantic_query")
local sha256 = require("linkedspec.sha256")

local M = {}

local SERVER_NAME = "linkedspec-semantic-lua"
local AUTHORIZATION_MAXIMUM_BYTES = 4096
local ENTROPY_BYTES = 32
local HANDLE_CHARACTERS = 43
local MAXIMUM_HANDLE_ATTEMPTS = 16
local MAXIMUM_SAFE_INTEGER = 9007199254740991
local DUMMY_AUTHORIZATION_DIGEST = string.rep("\0", 32)
local BASE64URL = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
local SOURCE_DETAIL_RANK = { none = 0, identity = 1, span = 2, text = 3 }

local SERVER_STATE = setmetatable({}, { __mode = "k" })
local BUDGET_STATE = setmetatable({}, { __mode = "k" })
local POLICY_STATE = setmetatable({}, { __mode = "k" })
local REGISTRATION_STATE = setmetatable({}, { __mode = "k" })
local ERROR_STATE = setmetatable({}, { __mode = "k" })
local SERVER_METHODS = {}

local function empty_pairs()
  return function() return nil end, nil, nil
end

local function immutable_newindex()
  error("MCP values are immutable", 0)
end

local function finite_integer(value)
  return type(value) == "number" and value == value and value ~= math.huge and
    value ~= -math.huge and value == math.floor(value) and
    value >= -MAXIMUM_SAFE_INTEGER and value <= MAXIMUM_SAFE_INTEGER
end

local function plain_options(value, allowed, label)
  if type(value) ~= "table" or getmetatable(value) ~= nil then
    error(label .. " options must be a plain table", 0)
  end
  local result = {}
  for name, item in next, value do
    if type(name) ~= "string" or not allowed[name] then
      error(label .. " options contain an unsupported field", 0)
    end
    result[name] = item
  end
  return result
end

local function error_index(value, key)
  local state = ERROR_STATE[value]
  if state == nil then return nil end
  return state[key]
end

local ERROR_MT = {
  __index = error_index,
  __newindex = immutable_newindex,
  __pairs = empty_pairs,
  __metatable = "protected",
  __tostring = function(value)
    local state = ERROR_STATE[value]
    if state == nil then return "McpServerError" end
    return state.code .. ": " .. state.message
  end,
}

local function mcp_error(code, message)
  local result = setmetatable({}, ERROR_MT)
  ERROR_STATE[result] = { code = code, message = message }
  return result
end

local function fail(code, message)
  error(mcp_error(code, message), 0)
end

function M.is_error(value)
  return ERROR_STATE[value] ~= nil
end

function M.error_to_json(value)
  local state = ERROR_STATE[value]
  if state == nil then
    fail("linkedspec_mcp_invalid_error", "Invalid MCP server error value.")
  end
  return json.harray({ code = state.code, message = state.message })
end

local function budget_index(value, key)
  local state = BUDGET_STATE[value]
  return state and state[key] or nil
end

local BUDGET_MT = {
  __index = budget_index,
  __newindex = immutable_newindex,
  __pairs = empty_pairs,
  __metatable = "protected",
  __tostring = function() return "McpBudgetLimits" end,
}

function M.budget_limits(options)
  local copied = plain_options(options, {
    max_records = true, max_relations = true, max_depth = true,
  }, "MCP budget")
  for _, name in ipairs({ "max_records", "max_relations", "max_depth" }) do
    local value = copied[name]
    if not finite_integer(value) or value < 0 then
      error("MCP budget " .. name .. " must be a nonnegative portable integer", 0)
    end
  end
  local result = setmetatable({}, BUDGET_MT)
  BUDGET_STATE[result] = {
    max_records = copied.max_records,
    max_relations = copied.max_relations,
    max_depth = copied.max_depth,
  }
  return result
end

local function policy_index(value, key)
  local state = POLICY_STATE[value]
  return state and state[key] or nil
end

local POLICY_MT = {
  __index = policy_index,
  __newindex = immutable_newindex,
  __pairs = empty_pairs,
  __metatable = "protected",
  __tostring = function() return "McpDeploymentPolicy" end,
}

function M.deployment_policy(options)
  options = options or {}
  local copied = plain_options(options, {
    source_detail_ceiling = true, page_max = true, budget_maxima = true,
  }, "MCP deployment policy")
  if copied.source_detail_ceiling ~= nil and
      SOURCE_DETAIL_RANK[copied.source_detail_ceiling] == nil then
    error("MCP source-detail policy is invalid", 0)
  end
  if copied.page_max ~= nil and
      (not finite_integer(copied.page_max) or copied.page_max < 1) then
    error("MCP page policy must be a positive portable integer", 0)
  end
  if copied.budget_maxima ~= nil and BUDGET_STATE[copied.budget_maxima] == nil then
    error("MCP budget policy must be an McpBudgetLimits value", 0)
  end
  local result = setmetatable({}, POLICY_MT)
  POLICY_STATE[result] = {
    source_detail_ceiling = copied.source_detail_ceiling,
    page_max = copied.page_max,
    budget_maxima = copied.budget_maxima,
  }
  return result
end

local function registration_index(value, key)
  local state = REGISTRATION_STATE[value]
  return state and state[key] or nil
end

local REGISTRATION_MT = {
  __index = registration_index,
  __newindex = immutable_newindex,
  __pairs = empty_pairs,
  __metatable = "protected",
  __tostring = function() return "McpRegistrationOptions" end,
}

function M.registration_options(options)
  options = options or {}
  local copied = plain_options(options, { lifetime_ms = true, policy = true },
    "MCP registration")
  if copied.lifetime_ms ~= nil and not finite_integer(copied.lifetime_ms) then
    error("MCP registration lifetime must be a portable integer", 0)
  end
  if copied.policy ~= nil and POLICY_STATE[copied.policy] == nil then
    error("MCP registration policy must be an McpDeploymentPolicy value", 0)
  end
  local result = setmetatable({}, REGISTRATION_MT)
  REGISTRATION_STATE[result] = {
    lifetime_ms = copied.lifetime_ms,
    policy = copied.policy,
  }
  return result
end

local function server_index(value, key)
  if SERVER_STATE[value] == nil then return nil end
  return SERVER_METHODS[key]
end

local SERVER_MT = {
  __index = server_index,
  __newindex = immutable_newindex,
  __pairs = empty_pairs,
  __metatable = "protected",
  __tostring = function(value)
    local state = SERVER_STATE[value]
    return "McpServer(stopped=" .. tostring(state == nil or state.stopped) .. ")"
  end,
}

local function server_state(value)
  local state = SERVER_STATE[value]
  if state == nil then fail("linkedspec_mcp_invalid_server", "MCP server object is invalid.") end
  return state
end

local function contract_registry()
  local ok, contract = pcall(runtime.contract)
  local registry = ok and json.kind(contract) == "harray" and contract.handle_registry or nil
  if json.kind(registry) ~= "harray" or
      not finite_integer(registry.default_maximum_live_handles) or
      not finite_integer(registry.default_lifetime_ms) or
      not finite_integer(registry.maximum_lifetime_ms) or
      registry.default_maximum_live_handles < 1 or registry.default_lifetime_ms < 1 or
      registry.maximum_lifetime_ms < registry.default_lifetime_ms then
    fail("linkedspec_mcp_contract_failure", "The generated MCP contract is unavailable.")
  end
  return registry
end

local function construct(dependencies)
  local result = setmetatable({}, SERVER_MT)
  SERVER_STATE[result] = {
    entries = {},
    active = {},
    stopped = false,
    entropy = dependencies.entropy,
    now_ms = dependencies.now_ms,
    maximum_handles = dependencies.maximum_handles,
    handle_attempts = dependencies.handle_attempts,
    default_lifetime_ms = dependencies.default_lifetime_ms,
    maximum_lifetime_ms = dependencies.maximum_lifetime_ms,
    capabilities_of = dependencies.capabilities_of,
    query_index = dependencies.query_index,
  }
  return result
end

local function native_capabilities(index)
  return semantic_query.to_json(index:capabilities())
end

local function native_query(index, request)
  return semantic_query.to_json(index:query_neutral(request))
end

function M.server(...)
  if select("#", ...) ~= 0 then
    fail("linkedspec_mcp_invalid_constructor", "Production MCP construction accepts no arguments.")
  end
  local ok, system = pcall(require, "linkedspec_mcp_system")
  if not ok or type(system) ~= "table" or type(system.secure_random_32) ~= "function" or
      type(system.monotonic_milliseconds) ~= "function" then
    fail("linkedspec_mcp_contract_failure", "The MCP native system module is unavailable.")
  end
  local registry = contract_registry()
  return construct({
    entropy = system.secure_random_32,
    now_ms = system.monotonic_milliseconds,
    maximum_handles = registry.default_maximum_live_handles,
    handle_attempts = MAXIMUM_HANDLE_ATTEMPTS,
    default_lifetime_ms = registry.default_lifetime_ms,
    maximum_lifetime_ms = registry.maximum_lifetime_ms,
    capabilities_of = native_capabilities,
    query_index = native_query,
  })
end

-- Package-private deterministic proof seam; deliberately absent from the root API.
function M._server_for_testing(options)
  local copied = plain_options(options, {
    entropy = true, now_ms = true, maximum_handles = true,
    handle_attempts = true, capabilities_of = true, query_index = true,
  }, "MCP test server")
  if type(copied.entropy) ~= "function" or type(copied.now_ms) ~= "function" then
    error("MCP test server requires entropy and monotonic-time callbacks", 0)
  end
  local registry = contract_registry()
  local maximum = copied.maximum_handles or 4
  local attempts = copied.handle_attempts or MAXIMUM_HANDLE_ATTEMPTS
  if not finite_integer(maximum) or maximum < 1 or
      maximum > registry.default_maximum_live_handles then
    error("MCP test registry capacity is outside the production bound", 0)
  end
  if not finite_integer(attempts) or attempts < 1 or attempts > MAXIMUM_HANDLE_ATTEMPTS then
    error("MCP test collision bound is outside the production bound", 0)
  end
  if copied.capabilities_of ~= nil and type(copied.capabilities_of) ~= "function" then
    error("MCP test capabilities seam must be a function", 0)
  end
  if copied.query_index ~= nil and type(copied.query_index) ~= "function" then
    error("MCP test query seam must be a function", 0)
  end
  return construct({
    entropy = copied.entropy,
    now_ms = copied.now_ms,
    maximum_handles = maximum,
    handle_attempts = attempts,
    default_lifetime_ms = registry.default_lifetime_ms,
    maximum_lifetime_ms = registry.maximum_lifetime_ms,
    capabilities_of = copied.capabilities_of or native_capabilities,
    query_index = copied.query_index or native_query,
  })
end

local function authorization_digest(value)
  if type(value) ~= "string" or #value < 1 or #value > AUTHORIZATION_MAXIMUM_BYTES then
    fail("linkedspec_mcp_invalid_authorization",
      "Authorization context must be 1 through 4096 opaque bytes.")
  end
  local hex = sha256.hex(value)
  local bytes = {}
  for position = 1, #hex, 2 do
    bytes[#bytes + 1] = string.char(tonumber(hex:sub(position, position + 1), 16))
  end
  return table.concat(bytes)
end

local function fixed_digest_equal(left, right)
  local different = #left == #right and 0 or 1
  for index = 1, 32 do
    if (left:byte(index) or 0) ~= (right:byte(index) or 0) then different = different + 1 end
  end
  return different == 0
end

local function base64url(bytes)
  local output = {}
  local position = 1
  while position <= #bytes do
    local remaining = #bytes - position + 1
    local first = bytes:byte(position)
    local second = remaining >= 2 and bytes:byte(position + 1) or 0
    local third = remaining >= 3 and bytes:byte(position + 2) or 0
    local value = first * 65536 + second * 256 + third
    output[#output + 1] = BASE64URL:sub(math.floor(value / 262144) % 64 + 1,
      math.floor(value / 262144) % 64 + 1)
    output[#output + 1] = BASE64URL:sub(math.floor(value / 4096) % 64 + 1,
      math.floor(value / 4096) % 64 + 1)
    if remaining >= 2 then
      output[#output + 1] = BASE64URL:sub(math.floor(value / 64) % 64 + 1,
        math.floor(value / 64) % 64 + 1)
    end
    if remaining >= 3 then
      output[#output + 1] = BASE64URL:sub(value % 64 + 1, value % 64 + 1)
    end
    position = position + 3
  end
  return table.concat(output)
end

local function valid_handle(value)
  return type(value) == "string" and #value == HANDLE_CHARACTERS and
    value:match("^[A-Za-z0-9_-]+$") ~= nil
end

local function unique_handle(state)
  for _ = 1, state.handle_attempts do
    local ok, bytes = pcall(state.entropy)
    if not ok or type(bytes) ~= "string" or #bytes ~= ENTROPY_BYTES then
      fail("linkedspec_mcp_entropy_failure", "Operating-system entropy is unavailable.")
    end
    local handle = base64url(bytes)
    if not valid_handle(handle) then
      fail("linkedspec_mcp_entropy_failure", "Operating-system entropy produced an invalid handle.")
    end
    if state.entries[handle] == nil then return handle end
  end
  fail("linkedspec_mcp_entropy_failure", "A unique MCP handle could not be generated.")
end

local function now_ms(state)
  local ok, value = pcall(state.now_ms)
  if not ok or not finite_integer(value) or value < 0 then
    fail("linkedspec_mcp_clock_failure", "Monotonic time is unavailable.")
  end
  return value
end

local function prune_expired(state, now)
  for handle, entry in next, state.entries do
    if now >= entry.expires_ms then state.entries[handle] = nil end
  end
end

local function budget_copy(value)
  return {
    max_records = value.max_records,
    max_relations = value.max_relations,
    max_depth = value.max_depth,
  }
end

local function budget_from_json(value)
  if json.kind(value) ~= "harray" then return nil end
  local count = 0
  for _ in next, value do count = count + 1 end
  if count ~= 3 then return nil end
  for _, name in ipairs({ "max_records", "max_relations", "max_depth" }) do
    if not finite_integer(value[name]) or value[name] < 0 then return nil end
  end
  return budget_copy(value)
end

local function native_limits(response)
  if json.kind(response) ~= "harray" or json.kind(response.records) ~= "array" then return nil end
  local capabilities
  local count = 0
  for index = 1, #response.records do
    local row = response.records[index]
    if json.kind(row) == "harray" and row.kind == "capabilities" then
      capabilities = row
      count = count + 1
    end
  end
  local facts = count == 1 and json.kind(capabilities.facts) == "harray" and capabilities.facts or nil
  local snapshot = json.kind(response.snapshot) == "harray" and response.snapshot or nil
  if facts == nil or snapshot == nil or SOURCE_DETAIL_RANK[facts.source_detail_ceiling] == nil or
      SOURCE_DETAIL_RANK[snapshot.source_detail_ceiling] == nil or
      not finite_integer(facts.page_default) or facts.page_default < 1 or
      not finite_integer(facts.page_max) or facts.page_max < 1 or
      facts.page_default > facts.page_max or type(snapshot.content_digest_available) ~= "boolean" then
    return nil
  end
  local defaults = budget_from_json(facts.budget_defaults)
  local maxima = budget_from_json(facts.budget_maxima)
  if defaults == nil or maxima == nil then return nil end
  for _, name in ipairs({ "max_records", "max_relations", "max_depth" }) do
    if defaults[name] > maxima[name] then return nil end
  end
  return {
    source_detail_ceiling = facts.source_detail_ceiling,
    content_digest_available = snapshot.content_digest_available,
    page_default = facts.page_default,
    page_max = facts.page_max,
    budget_defaults = defaults,
    budget_maxima = maxima,
  }
end

local function effective_policy(policy_value, native)
  local effective = {
    source_detail_ceiling = native.source_detail_ceiling,
    content_digest_available = native.content_digest_available,
    page_default = native.page_default,
    page_max = native.page_max,
    budget_defaults = budget_copy(native.budget_defaults),
    budget_maxima = budget_copy(native.budget_maxima),
    project = policy_value ~= nil,
  }
  if policy_value == nil then return effective end
  local supplied = POLICY_STATE[policy_value]
  if supplied == nil then fail("linkedspec_mcp_invalid_policy", "MCP deployment policy is invalid.") end
  if supplied.source_detail_ceiling ~= nil then
    if SOURCE_DETAIL_RANK[supplied.source_detail_ceiling] >
        SOURCE_DETAIL_RANK[native.source_detail_ceiling] then
      fail("linkedspec_mcp_invalid_policy", "MCP source-detail policy is invalid or elevating.")
    end
    effective.source_detail_ceiling = supplied.source_detail_ceiling
    if supplied.source_detail_ceiling ~= "text" then effective.content_digest_available = false end
  end
  if supplied.page_max ~= nil then
    if supplied.page_max > native.page_max then
      fail("linkedspec_mcp_invalid_policy", "MCP page policy is invalid or elevating.")
    end
    effective.page_max = supplied.page_max
    effective.page_default = math.min(effective.page_default, supplied.page_max)
  end
  if supplied.budget_maxima ~= nil then
    local budget = BUDGET_STATE[supplied.budget_maxima]
    if budget == nil then fail("linkedspec_mcp_invalid_policy", "MCP budget policy is invalid.") end
    for _, name in ipairs({ "max_records", "max_relations", "max_depth" }) do
      if budget[name] > native.budget_maxima[name] then
        fail("linkedspec_mcp_invalid_policy", "MCP budget policy is invalid or elevating.")
      end
      effective.budget_maxima[name] = budget[name]
      effective.budget_defaults[name] = math.min(effective.budget_defaults[name], budget[name])
    end
  end
  return effective
end

function SERVER_METHODS.register_index(server, index, authorization_context, options)
  local state = server_state(server)
  if state.stopped then fail("linkedspec_mcp_server_shutdown", "The MCP server has shut down.") end
  if not semantic_index._is_index(index) then
    fail("linkedspec_mcp_invalid_index", "MCP registration requires a native Lua semantic index.")
  end
  local authorization = authorization_digest(authorization_context)
  local registration = options == nil and { lifetime_ms = nil, policy = nil } or REGISTRATION_STATE[options]
  if registration == nil then
    fail("linkedspec_mcp_invalid_registration", "Invalid MCP registration options.")
  end
  local lifetime = registration.lifetime_ms or state.default_lifetime_ms
  if not finite_integer(lifetime) or lifetime < 1 or lifetime > state.maximum_lifetime_ms then
    fail("linkedspec_mcp_invalid_registration", "Registration lifetime is outside the contract bounds.")
  end
  local now = now_ms(state)
  prune_expired(state, now)
  local count = 0
  for _ in next, state.entries do count = count + 1 end
  if count >= state.maximum_handles then
    fail("linkedspec_mcp_registry_full", "The MCP handle registry is at capacity.")
  end
  local ok, capabilities = pcall(state.capabilities_of, index)
  if not ok then capabilities = nil end
  if capabilities ~= nil then
    local copied_ok, copied = pcall(runtime.clone_data, capabilities)
    capabilities = copied_ok and copied or nil
  end
  if capabilities == nil or not runtime.validate_named("semanticQueryResponse", capabilities) then
    fail("linkedspec_mcp_invalid_index", "The semantic index did not provide valid capabilities.")
  end
  local native = native_limits(capabilities)
  if native == nil then
    fail("linkedspec_mcp_invalid_index", "The semantic index capability limits are invalid.")
  end
  local policy = effective_policy(registration.policy, native)
  if now > MAXIMUM_SAFE_INTEGER - lifetime then
    fail("linkedspec_mcp_clock_failure", "Monotonic time is unavailable.")
  end
  local handle = unique_handle(state)
  state.entries[handle] = {
    index = index,
    authorization_digest = authorization,
    expires_ms = now + lifetime,
    policy = policy,
  }
  return handle
end

function SERVER_METHODS.revoke_handle(server, handle)
  local state = server_state(server)
  if not valid_handle(handle) then
    fail("linkedspec_mcp_invalid_handle", "MCP handle syntax is invalid.")
  end
  state.entries[handle] = nil
  return true
end

local function protocol_error(id, kind, requested)
  local ok, response = pcall(runtime.json_rpc_error, id, kind, requested)
  if ok then return response end
  return json.harray({
    jsonrpc = "2.0",
    id = id == nil and json.null or id,
    error = json.harray({ code = -32603, message = "Internal error" }),
  })
end

local function requested_protocol(request)
  local params = json.kind(request.params) == "harray" and request.params or nil
  local metadata = params and json.kind(params._meta) == "harray" and params._meta or nil
  return metadata and metadata["io.modelcontextprotocol/protocolVersion"] or nil
end

local function authorized_entry(state, handle, authorization)
  local entry = type(handle) == "string" and state.entries[handle] or nil
  local expected = entry and entry.authorization_digest or DUMMY_AUTHORIZATION_DIGEST
  local equal = fixed_digest_equal(expected, authorization)
  local now = now_ms(state)
  if entry ~= nil and now >= entry.expires_ms then
    state.entries[handle] = nil
    entry = nil
  end
  if entry ~= nil and equal then return entry end
  return nil
end

local function project_capabilities(response, policy)
  if not policy.project then return response end
  local projected = runtime.clone_data(response)
  local capabilities
  local count = 0
  for index = 1, #projected.records do
    local row = projected.records[index]
    if row.kind == "capabilities" then capabilities, count = row, count + 1 end
  end
  if count ~= 1 or json.kind(capabilities.facts) ~= "harray" then error("invalid capabilities", 0) end
  local facts = capabilities.facts
  facts.source_detail_ceiling = policy.source_detail_ceiling
  facts.page_max = policy.page_max
  facts.page_default = policy.page_default
  facts.budget_maxima = json.harray(budget_copy(policy.budget_maxima))
  facts.budget_defaults = json.harray(budget_copy(policy.budget_defaults))
  projected.snapshot.source_detail_ceiling = policy.source_detail_ceiling
  projected.snapshot.content_digest_available =
    policy.content_digest_available and policy.source_detail_ceiling == "text"
  return projected
end

local function request_within_policy(request, policy)
  local source = json.kind(request) == "harray" and request.source or nil
  if json.kind(source) ~= "harray" or SOURCE_DETAIL_RANK[source.detail] == nil or
      SOURCE_DETAIL_RANK[source.detail] > SOURCE_DETAIL_RANK[policy.source_detail_ceiling] then
    return false
  end
  if source.include_content_digest and
      (not policy.content_digest_available or policy.source_detail_ceiling ~= "text") then
    return false
  end
  local page = request.page
  if json.kind(page) ~= "harray" or not finite_integer(page.limit) or page.limit > policy.page_max then
    return false
  end
  local budget = budget_from_json(request.budget)
  if budget == nil then return false end
  for _, name in ipairs({ "max_records", "max_relations", "max_depth" }) do
    if budget[name] > policy.budget_maxima[name] then return false end
  end
  return true
end

local function prepare_response(state, id, retain_prepared, builder)
  local key_ok, key = pcall(runtime.canonical_json, id)
  if not key_ok or state.active[key] ~= nil then return protocol_error(id, "internal_error") end
  local active = { cancelled = false, prepared = false }
  state.active[key] = active
  local ok, response = pcall(builder)
  if active.cancelled then
    state.active[key] = nil
    return nil
  end
  if not ok then
    state.active[key] = nil
    return protocol_error(id, "internal_error")
  end
  if retain_prepared then active.prepared = true else state.active[key] = nil end
  return response
end

local function dispatch(server, request, authorization_context, retain_prepared)
  local state = server_state(server)
  local authorization = authorization_digest(authorization_context)
  local copy_ok, copy = pcall(runtime.clone_data, request)
  if not copy_ok then return protocol_error(nil, "invalid_request") end
  local id_candidate = json.kind(copy) == "harray" and copy.id or nil
  local id = id_candidate ~= nil and runtime.validate_named("requestId", id_candidate) and id_candidate or nil
  if state.stopped then return protocol_error(id, "internal_error") end
  if json.kind(copy) ~= "harray" or copy.jsonrpc ~= "2.0" or type(copy.method) ~= "string" then
    return protocol_error(nil, "invalid_request")
  end
  local method = copy.method
  local has_id = rawget(copy, "id") ~= nil
  if not has_id then
    if method == "notifications/cancelled" and runtime.validate_named("cancelledNotification", copy) then
      local key_ok, key = pcall(runtime.canonical_json, copy.params.requestId)
      if key_ok and state.active[key] ~= nil then state.active[key].cancelled = true end
    end
    return nil
  end
  if id == nil then return protocol_error(nil, "invalid_request") end
  if method == "initialize" then return protocol_error(id, "legacy_initialize") end
  if method == "notifications/cancelled" then return protocol_error(id, "invalid_request") end
  if method ~= "server/discover" and method ~= "tools/list" and method ~= "tools/call" then
    return protocol_error(id, "method_not_found")
  end
  local protocol = requested_protocol(copy)
  if type(protocol) == "string" and protocol ~= runtime.protocol_version() then
    return protocol_error(id, "unsupported_version", protocol)
  end
  if method == "server/discover" then
    if not runtime.validate_named("discoverRequest", copy) then
      return protocol_error(id, "invalid_params")
    end
    return prepare_response(state, id, retain_prepared, function()
      return runtime.discover_response(id)
    end)
  end
  if method == "tools/list" then
    if not runtime.validate_named("toolsListRequest", copy) then
      return protocol_error(id, "invalid_params")
    end
    return prepare_response(state, id, retain_prepared, function()
      return runtime.tools_list_response(id)
    end)
  end

  local params = json.kind(copy.params) == "harray" and copy.params or nil
  local name = params and params.name or nil
  local definition
  local operation
  if name == "linkedspec_semantic_capabilities" then
    definition, operation = "capabilitiesCallRequest", "capabilities"
  elseif name == "linkedspec_semantic_query" then
    definition, operation = "semanticQueryCallRequest", "query"
  else
    return protocol_error(id, "invalid_params")
  end
  if not runtime.validate_named(definition, copy) then return protocol_error(id, "invalid_params") end
  return prepare_response(state, id, retain_prepared, function()
    local arguments = copy.params.arguments
    local entry = authorized_entry(state, arguments.handle, authorization)
    if entry == nil then return runtime.tool_error_response(id, true) end
    if operation == "query" and not request_within_policy(arguments.request, entry.policy) then
      return runtime.tool_error_response(id, false)
    end
    local ok, payload
    if operation == "capabilities" then
      ok, payload = pcall(state.capabilities_of, entry.index)
      if ok then payload = project_capabilities(payload, entry.policy) end
    else
      ok, payload = pcall(state.query_index, entry.index, runtime.clone_data(arguments.request))
    end
    if not ok then error("native query failed", 0) end
    local copy_ok, copied = pcall(runtime.clone_data, payload)
    if not copy_ok or not runtime.validate_named("semanticQueryResponse", copied) then
      error("native response invalid", 0)
    end
    return runtime.tool_success_response(id, copied)
  end)
end

function SERVER_METHODS.dispatch(server, request, authorization_context)
  return dispatch(server, request, authorization_context, false)
end

function M._dispatch_for_wire(server, request, authorization_context)
  local response = dispatch(server, request, authorization_context, true)
  if response == nil or json.kind(request) ~= "harray" or request.id == nil then return response, nil end
  local ok, key = pcall(runtime.canonical_json, request.id)
  local state = server_state(server)
  if ok and state.active[key] ~= nil and state.active[key].prepared then return response, key end
  return response, nil
end

function M._wire_response_ready(server, key)
  local state = server_state(server)
  local active = type(key) == "string" and state.active[key] or nil
  if active == nil then return false end
  if active.cancelled then state.active[key] = nil return false end
  return active.prepared
end

function M._wire_response_emitted(server, key)
  local state = server_state(server)
  if type(key) == "string" then state.active[key] = nil end
  return true
end

function SERVER_METHODS.shutdown(server)
  local state = server_state(server)
  state.stopped = true
  state.entries = {}
  state.active = {}
  return true
end

function M._registered_handles(server)
  local count = 0
  for _ in next, server_state(server).entries do count = count + 1 end
  return count
end

function M._active_requests(server)
  local count = 0
  for _ in next, server_state(server).active do count = count + 1 end
  return count
end

M.SERVER_NAME = SERVER_NAME

return M
