-- FUTURE-PARITY-BACKLOG.14.6.6.1 — private shared Lua progressive authority.
--
-- Ordinary Lua and canonical CI discovery deliberately ignore test_dormant/.
-- Run this same Lua-5.1-compatible source through both admitted hosts:
--
--   bash tools/run_lua_project_data.sh puc lua/test_dormant/progressive_span_dispatch_authority_test.lua
--   bash tools/run_lua_project_data.sh luajit lua/test_dormant/progressive_span_dispatch_authority_test.lua
--
-- The separate final-path consumer must remain 85-pass/one-RED until carrier
-- leaf `.14.6.6.2` adds its dedicated node and four execution routes.

local json = require("linkedspec.json")
local linkedspec = require("linkedspec")
local authority = require("linkedspec.bounded_child_parse_authority")

local assertions = 0
local failures = {}

local function check(condition, label)
  assertions = assertions + 1
  if not condition then failures[#failures + 1] = label end
end

local function check_equal(actual, expected, label)
  check(
    actual == expected,
    label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual)
  )
end

local function check_same_json(actual, expected, label)
  check_equal(json.encode(actual), json.encode(expected), label)
end

local function read_all(path)
  local handle, open_error = io.open(path, "rb")
  if handle == nil then error("cannot read " .. path .. ": " .. tostring(open_error), 0) end
  local content = handle:read("*a")
  handle:close()
  return content
end

local function capture(operation)
  local ok, value = pcall(operation)
  if ok then return nil, value end
  return value, nil
end

local contract = json.decode(read_all(
  "capability_conformance/progressive_span_dispatch_contract.json"
))
local origin = "progressive_span_dispatch_authority"
local observed = {}

local function remember(operation, label)
  local failure = capture(operation)
  check(authority.is_dispatch_error(failure), label .. " returns a typed dispatch error")
  if not authority.is_dispatch_error(failure) then return nil end
  local code = authority.diagnostic_code(failure)
  observed[code] = authority.to_json(failure)
  return code
end

local function ceilings_from(value)
  return authority.ceilings({
    source_detail = value.source_detail,
    policy_modes = value.policy_modes,
    max_steps = value.max_steps,
    max_result_nodes = value.max_result_nodes,
    max_diagnostic_bytes = value.max_diagnostic_bytes,
  })
end

local function permissive_ceilings()
  return authority.ceilings({
    source_detail = "text",
    policy_modes = json.array({
      "deterministic",
      "fail-only",
      "strict-json",
      "trace",
    }),
    max_steps = 1000,
    max_result_nodes = 1000,
    max_diagnostic_bytes = 4096,
  })
end

local function registry_for(callback)
  local entries = json.array()
  for index, row in ipairs(contract.registry_entries) do
    entries[index] = authority.registry_entry({
      parser_id = row.parser_id,
      compiled_authority = callback,
      fingerprint = row.fingerprint,
      allowed_top_rules = row.allowed_top_rules,
      capabilities = row.capabilities,
      ceilings = ceilings_from(row.ceilings),
    })
  end
  return authority.registry({ entries = entries })
end

local function invocation_options(options)
  options = options or {}
  local sources = json.harray()
  for _, row in ipairs(contract.sources) do sources[row.id] = row.text end
  return {
    sources = sources,
    source_id = options.source_id or "unicode",
    cancellation_token = options.token,
    now = function() return options.now_tick or 1 end,
    deadline_tick = options.deadline_tick or 100,
    remaining_steps = options.remaining_steps == nil and 100 or options.remaining_steps,
    max_depth = options.max_depth or 8,
    total_calls = options.total_calls or 0,
    max_calls = options.max_calls or 16,
    active_chain = options.active_chain or json.array(),
  }
end

local function dispatch_options(options)
  return {
    origin = origin,
    parser_id = options.parser_id,
    top_rule = options.top_rule,
    span = options.span,
    caller_capabilities = options.caller_capabilities or json.array({
      "actionir-v1",
      "caller-only",
      "structured-result-v1",
      "typed-source-location-v1",
    }),
    required_capabilities = options.required_capabilities or json.array(),
    caller_ceilings = options.caller_ceilings or permissive_ceilings(),
    required_source_detail = options.required_source_detail or "none",
    child_token = options.token,
    cost = options.cost,
    transaction_active = options.transaction_active or false,
  }
end

local function direct_span(source_id, start_offset, end_offset, provenance)
  return json.harray({
    source_id = source_id,
    start = start_offset,
    ["end"] = end_offset,
    provenance = provenance,
  })
end

-- Execute every neutral row and collect every governed diagnostic code.
local view_registry = registry_for(function(request)
  local view = authority.request_source_view(request)
  local offsets = json.array()
  local text = authority.view_text(view)
  local scalar_length = authority.view_scalar_length(view)
  for offset = 0, scalar_length do
    offsets[#offsets + 1] = authority.local_to_global(view, offset)
  end
  return json.harray({ text = text, offsets = offsets })
end)

for _, row in ipairs(contract.view_cases) do
  local token = authority.cancellation_token()
  local invocation = authority.start_invocation(
    view_registry,
    invocation_options({ source_id = row.authority_source_id, token = token })
  )
  local options = dispatch_options({
    parser_id = "expr-v1",
    top_rule = "Expr",
    span = row.span,
    token = token,
    cost = 1,
  })
  if row.accepted then
    local result = authority.dispatch(invocation, options)
    check_equal(result.text, row.view_text, "view " .. row.id .. " text")
    check_same_json(result.offsets, row.local_to_global, "view " .. row.id .. " rebasing")
  else
    check_equal(
      remember(function() authority.dispatch(invocation, options) end, "view " .. row.id),
      row.diagnostic,
      "view " .. row.id .. " diagnostic"
    )
  end
end

for _, row in ipairs(contract.authority_cases) do
  local effective_seen = nil
  local current_registry = registry_for(function(request)
    effective_seen = authority.effective_to_json(authority.request_effective(request))
    return false
  end)
  local token = authority.cancellation_token()
  local invocation = authority.start_invocation(
    current_registry,
    invocation_options({ source_id = "unicode", token = token })
  )
  local top_rule = row.entry_id == "json-v1" and "Document" or "Expr"
  local options = dispatch_options({
    parser_id = row.entry_id,
    top_rule = top_rule,
    span = direct_span("unicode", 0, 1, "authority-case"),
    token = token,
    cost = 1,
    caller_capabilities = row.caller_capabilities,
    required_capabilities = row.required_capabilities,
    caller_ceilings = ceilings_from(row.caller_ceilings),
    required_source_detail = row.required_source_detail,
  })
  if row.accepted then
    check(authority.dispatch(invocation, options) == false, "authority " .. row.id .. " preserves false")
    check_same_json(effective_seen, row.effective, "authority " .. row.id .. " intersection")
  else
    check_equal(
      remember(function() authority.dispatch(invocation, options) end, "authority " .. row.id),
      row.diagnostic,
      "authority " .. row.id .. " diagnostic"
    )
  end
end

local success_registry = registry_for(function() return true end)
for _, row in ipairs(contract.cancellation_cases) do
  local token = authority.cancellation_token()
  if row.cancelled then authority.cancel(token) end
  local child_token = row.token == row.child_token and token or authority.cancellation_token()
  local invocation = authority.start_invocation(success_registry, invocation_options({
    source_id = "unicode",
    token = token,
    now_tick = row.now_tick,
    deadline_tick = row.deadline_tick,
    remaining_steps = row.remaining_steps,
  }))
  local options = dispatch_options({
    parser_id = "expr-v1",
    top_rule = "Expr",
    span = direct_span("unicode", 0, 1, "safe-point"),
    token = child_token,
    cost = row.cost,
  })
  if row.accepted then
    check(authority.dispatch(invocation, options) == true, "cancellation " .. row.id .. " result")
  else
    check_equal(
      remember(function() authority.dispatch(invocation, options) end, "cancellation " .. row.id),
      row.diagnostic,
      "cancellation " .. row.id .. " diagnostic"
    )
  end
  check_equal(authority.remaining_steps(invocation), row.remaining_after, "cancellation " .. row.id .. " budget")
end

for _, row in ipairs(contract.chain_cases) do
  local active_chain = json.array()
  for index, frame in ipairs(row.active) do
    active_chain[index] = authority.chain_frame({
      parser_id = frame[1],
      top_rule = frame[2],
      source_id = frame[3],
      start = frame[4],
      ["end"] = frame[5],
    })
  end
  local candidate = row.candidate
  local token = authority.cancellation_token()
  local invocation = authority.start_invocation(success_registry, invocation_options({
    source_id = candidate[3],
    token = token,
    max_depth = row.max_depth,
    total_calls = row.total_calls,
    max_calls = row.max_calls,
    active_chain = active_chain,
  }))
  local options = dispatch_options({
    parser_id = candidate[1],
    top_rule = candidate[2],
    span = direct_span(candidate[3], candidate[4], candidate[5], "chain-case"),
    token = token,
    cost = 1,
  })
  if row.accepted then
    check(authority.dispatch(invocation, options) == true, "chain " .. row.id .. " result")
  else
    check_equal(
      remember(function() authority.dispatch(invocation, options) end, "chain " .. row.id),
      row.diagnostic,
      "chain " .. row.id .. " diagnostic"
    )
  end
end

for _, row in ipairs(contract.execution_cases) do
  local child_result = row.child_result
  if child_result == json.null then child_result = nil end
  local execution_registry = registry_for(function() return child_result end)
  local token = authority.cancellation_token()
  local parent_state = json.decode(json.encode(row.parent_before))
  local invocation = authority.start_invocation(execution_registry, invocation_options({
    source_id = "unicode",
    token = token,
    remaining_steps = row.budget_before,
  }))
  local options = dispatch_options({
    parser_id = "expr-v1",
    top_rule = "Expr",
    span = direct_span("unicode", 1, 4, "execution-case"),
    token = token,
    cost = row.child_cost,
  })
  if row.accepted then
    check_same_json(authority.dispatch(invocation, options), row.child_result, "execution " .. row.id .. " result")
  else
    check_equal(
      remember(function() authority.dispatch(invocation, options) end, "execution " .. row.id),
      row.diagnostic,
      "execution " .. row.id .. " diagnostic"
    )
  end
  check_same_json(parent_state, row.parent_after, "execution " .. row.id .. " parent isolation")
  check_equal(authority.remaining_steps(invocation), row.budget_after, "execution " .. row.id .. " budget")
end

local seam_token = authority.cancellation_token()
local seam_invocation = authority.start_invocation(
  success_registry,
  invocation_options({ source_id = "unicode", token = seam_token })
)
local valid_span = direct_span("unicode", 0, 1, "seam")
local seam_calls = {
  dispatch_options({ parser_id = 17, top_rule = "Expr", span = valid_span, token = seam_token, cost = 1 }),
  dispatch_options({ parser_id = "BAD", top_rule = "Expr", span = valid_span, token = seam_token, cost = 1 }),
  dispatch_options({ parser_id = "expr-v1", top_rule = {}, span = valid_span, token = seam_token, cost = 1 }),
  dispatch_options({ parser_id = "expr-v1", top_rule = "bad/rule", span = valid_span, token = seam_token, cost = 1 }),
  dispatch_options({ parser_id = "expr-v1", top_rule = "Expr", span = "copied", token = seam_token, cost = 1 }),
  dispatch_options({ parser_id = "missing-v1", top_rule = "Expr", span = valid_span, token = seam_token, cost = 1 }),
  dispatch_options({ parser_id = "expr-v1", top_rule = "Document", span = valid_span, token = seam_token, cost = 1 }),
  dispatch_options({ parser_id = "expr-v1", top_rule = "Expr", span = valid_span, token = seam_token, cost = 1, transaction_active = true }),
}
for index, options in ipairs(seam_calls) do
  remember(function() authority.dispatch(seam_invocation, options) end, "diagnostic seam " .. index)
end
remember(function() authority.register(success_registry, "expr-v1") end, "registry mutation")
remember(function() authority.load(success_registry, "expr-v1") end, "implicit load")

local diagnostic_rows = {}
for _, row in ipairs(contract.diagnostics) do diagnostic_rows[row.code] = row end
for code, row in pairs(diagnostic_rows) do
  local record = observed[code]
  check(record ~= nil, "diagnostic " .. code .. " observed")
  if record ~= nil then
    for _, field in ipairs(row.required_context) do
      check(record[field] ~= nil, "diagnostic " .. code .. " field " .. field)
    end
  end
end
for code in pairs(observed) do
  check(diagnostic_rows[code] ~= nil, "diagnostic " .. code .. " governed")
end

-- Nested callbacks share budget/chain authority, rebase typed values, then expire.
local retained_view = nil
local retained_request = nil
local nested_token = authority.cancellation_token()
local nested_registry
nested_registry = registry_for(function(request)
  retained_view = authority.request_source_view(request)
  retained_request = request
  local text = authority.view_text(retained_view)
  if authority.view_scalar_length(retained_view) > 3 then
    return authority.dispatch_nested(request, dispatch_options({
      parser_id = "expr-v1",
      top_rule = "Expr",
      span = direct_span("unicode", 1, 4, "nested"),
      token = nested_token,
      cost = 3,
    }))
  end
  return json.harray({
    text = text,
    position = authority.rebase_position(retained_view, 1),
    span = authority.rebase_span(retained_view, direct_span("unicode", 0, 2, "child-match")),
    diagnostic = authority.rebase_diagnostic(retained_view, json.harray({
      offset = 1,
      span = direct_span("unicode", 0, 2, "child-diagnostic"),
    })),
    effective = authority.effective_to_json(authority.request_effective(request)),
  })
end)
local nested_invocation = authority.start_invocation(nested_registry, invocation_options({
  source_id = "unicode",
  token = nested_token,
  remaining_steps = 20,
  max_depth = 4,
  max_calls = 8,
}))
local nested_result = authority.dispatch(nested_invocation, dispatch_options({
  parser_id = "expr-v1",
  top_rule = "Expr",
  span = direct_span("unicode", 0, 5, "outer"),
  token = nested_token,
  cost = 2,
}))
check_equal(nested_result.text, "é🙂B", "nested bounded text")
check_equal(nested_result.position.offset, 2, "nested position rebasing")
check_equal(nested_result.span.start, 1, "nested span start rebasing")
check_equal(nested_result.span["end"], 3, "nested span end rebasing")
check_equal(nested_result.diagnostic.offset, 2, "nested diagnostic offset rebasing")
check_equal(nested_result.diagnostic.span.start, 1, "nested diagnostic span start")
check_equal(nested_result.diagnostic.span["end"], 3, "nested diagnostic span end")
check_equal(authority.remaining_steps(nested_invocation), 15, "nested shared budget")
check_equal(authority.total_calls(nested_invocation), 2, "nested shared call count")
local expired_view = capture(function() authority.view_text(retained_view) end)
check(authority.is_source_view_error(expired_view), "retained source view expires")
local expired_request = capture(function()
  authority.dispatch_nested(retained_request, dispatch_options({
    parser_id = "expr-v1",
    top_rule = "Expr",
    span = direct_span("unicode", 2, 3, "expired"),
    token = nested_token,
    cost = 1,
  }))
end)
check(authority.is_source_view_error(expired_request), "retained nested request expires")

-- Trusted inputs and callback outputs are copied, deeply detached, and bounded.
local top_rules = json.array({ "Expr" })
local capabilities = json.array({ "typed-source-location-v1" })
local result_seed = json.harray({ kind = "seed", items = json.array({ 1 }) })
local detached_entry = authority.registry_entry({
  parser_id = "expr-v1",
  compiled_authority = function() return result_seed end,
  fingerprint = "sha256:" .. string.rep("1", 64),
  allowed_top_rules = top_rules,
  capabilities = capabilities,
  ceilings = authority.ceilings({
    source_detail = "span",
    policy_modes = json.array({ "deterministic" }),
    max_steps = 10,
    max_result_nodes = 16,
    max_diagnostic_bytes = 1024,
  }),
})
top_rules[1] = "Mutated"
capabilities[1] = "mutated"
local detached_registry = authority.registry({ entries = json.array({ detached_entry }) })
local detached_token = authority.cancellation_token()
local detached_invocation = authority.start_invocation(detached_registry, invocation_options({
  source_id = "unicode",
  token = detached_token,
  remaining_steps = 10,
}))
local detached = authority.dispatch(detached_invocation, dispatch_options({
  parser_id = "expr-v1",
  top_rule = "Expr",
  span = direct_span("unicode", 0, 1, "detachment"),
  token = detached_token,
  cost = 1,
  caller_capabilities = json.array({ "typed-source-location-v1" }),
  caller_ceilings = authority.ceilings({
    source_detail = "span",
    policy_modes = json.array({ "deterministic" }),
    max_steps = 10,
    max_result_nodes = 16,
    max_diagnostic_bytes = 1024,
  }),
}))
result_seed.kind = "mutated"
result_seed.items[2] = 2
check_same_json(detached, json.harray({ kind = "seed", items = json.array({ 1 }) }), "child result detached")

local function expect_result_rejection(callback, ceilings, label)
  local current_registry = registry_for(callback)
  local token = authority.cancellation_token()
  local invocation = authority.start_invocation(current_registry, invocation_options({ token = token, remaining_steps = 10 }))
  local code = remember(function()
    authority.dispatch(invocation, dispatch_options({
      parser_id = "expr-v1",
      top_rule = "Expr",
      span = direct_span("unicode", 0, 1, label),
      token = token,
      cost = 1,
      caller_ceilings = ceilings or permissive_ceilings(),
    }))
  end, label)
  check_equal(code, "progressive_result_not_detached", label .. " rejected")
end

expect_result_rejection(
  function() return json.array({ 1, 2 }) end,
  authority.ceilings({
    source_detail = "span",
    policy_modes = json.array({ "deterministic", "fail-only" }),
    max_steps = 10,
    max_result_nodes = 2,
    max_diagnostic_bytes = 1024,
  }),
  "oversized result"
)
local cyclic = json.harray()
cyclic.child = cyclic
expect_result_rejection(function() return cyclic end, nil, "cyclic result")
expect_result_rejection(function() return math.huge end, nil, "nonfinite result")
expect_result_rejection(function() return json.harray({ source_text = "secret" }) end, nil, "live-looking result")
local disguised_array = json.array({ 1 })
disguised_array.authority = "opaque:hidden"
expect_result_rejection(function() return disguised_array end, nil, "non-dense array result")

local diagnostic_registry = registry_for(function() error("éé", 0) end)
local diagnostic_token = authority.cancellation_token()
local diagnostic_invocation = authority.start_invocation(diagnostic_registry, invocation_options({
  token = diagnostic_token,
  remaining_steps = 10,
}))
local diagnostic_failure = capture(function()
  authority.dispatch(diagnostic_invocation, dispatch_options({
    parser_id = "expr-v1",
    top_rule = "Expr",
    span = direct_span("unicode", 0, 1, "diagnostic"),
    token = diagnostic_token,
    cost = 1,
    caller_ceilings = authority.ceilings({
      source_detail = "span",
      policy_modes = json.array({ "deterministic", "fail-only" }),
      max_steps = 10,
      max_result_nodes = 16,
      max_diagnostic_bytes = 1,
    }),
  }))
end)
check(authority.is_dispatch_error(diagnostic_failure), "child diagnostic returns typed error")
check_equal(authority.diagnostic_code(diagnostic_failure), "progressive_child_failed", "child diagnostic code")
check_equal(authority.to_json(diagnostic_failure).child_diagnostic, "?", "child diagnostic UTF-8 truncation")

-- The new authority stays private, dormant, ActionIR-independent, and carrier-free.
check(linkedspec.bounded_child_parse_authority == nil, "private authority absent from package facade")
local ordinary_driver = read_all("tools/run_lua_local.sh")
local canonical_driver = read_all("tools/run_ci_local.sh")
check(not ordinary_driver:find("progressive_span_dispatch_authority_test", 1, true), "authority absent from ordinary discovery")
check(not canonical_driver:find("progressive_span_dispatch_authority_test", 1, true), "authority absent from canonical discovery")
for _, path in ipairs({
  "lua/src/linkedspec/action_ast.lua",
  "lua/src/linkedspec/action_call_names.lua",
  "lua/src/linkedspec/action_contracts.lua",
  "lua/src/linkedspec/action_parser.lua",
  "lua/src/linkedspec/interpreter.lua",
}) do
  local content = read_all(path)
  check(not content:find("bounded_child_parse_authority", 1, true), path .. " has no authority carrier")
  check(not content:find("progressive_dispatch_span", 1, true), path .. " has no dedicated node")
end

if #failures > 0 then
  io.stderr:write(
    "Lua progressive span-dispatch authority: ",
    tostring(#failures),
    " of ",
    tostring(assertions),
    " assertions failed on ",
    tostring(_VERSION),
    "\n"
  )
  for _, failure in ipairs(failures) do io.stderr:write("- ", failure, "\n") end
  os.exit(1)
end

io.stdout:write(
  "Lua progressive span-dispatch authority: ",
  tostring(assertions),
  "/",
  tostring(assertions),
  " assertions passed on ",
  tostring(_VERSION),
  "\n"
)
